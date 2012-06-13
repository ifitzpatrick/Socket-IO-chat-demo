angular.module('chat', [])
       .controller('mainCtrl', ($scope, io) ->
         $scope.messages = []
         $scope.newMessage = ''
         $scope.user = ''
         $scope.addMessage = (message) ->
           $scope.messages.push message

         queue = []
         $scope.formatMessage = (message) ->
           if $scope.user.length then "#{$scope.user}: #{message}" else message
         $scope.sendMessage = (message) ->
           queue.push $scope.formatMessage message

         socket = io.connect '/'
         socket.on 'connect', ->
           $scope.$apply ->
             $scope.sendMessage = (message) ->
               socket.send $scope.formatMessage message

           for message in queue
             socket.send message

           socket.on 'message', (msg) ->
             $scope.$apply ->
               $scope.addMessage msg
       ).directive('keyDown', ->
         (scope, element, attrs) ->
           element.keydown (evt) ->
             if evt.which is +attrs['key'] or not attrs['key']
               scope.$apply (scope) ->
                 scope[attrs['keyDown']](element.val())

               element.val ''
       ).factory('io', -> io)
