angular.module('chat', [])
       .controller('mainCtrl', ($scope, Messenger) ->
         $scope.messages = []
         $scope.newMessage = ''
         $scope.user = ''
         $scope.addMessage = (message) ->
           $scope.messages.push message

         queue = []
         $scope.formatMessage = (message) ->
           if $scope.user.length then "#{$scope.user}: #{message}" else message

         chatMessenger = new Messenger '/', $scope, (msg) ->
           $scope.addMessage msg

         $scope.sendMessage = (message) ->
           $scope.newMessage = ''
           chatMessenger.sendMessage $scope.formatMessage message

       ).directive('pressEnter', ->
         (scope, element, attrs) ->
           element.keydown (evt) ->
             if evt.which is 13
               scope.$apply attrs['pressEnter']

       ).factory('io', -> io
       ).factory('Messenger', (io) ->
         class
           constructor: (route, scope, receiveMessage = ->) ->
             @socket = io.connect route
             @scope = scope

             @socket.on 'connect', =>
               @isConnected = true
               for message in @queue
                 @sendMessage message

               @socket.on 'message', (msg) =>
                 @scope.$apply ->
                   receiveMessage msg

           queue: []
           isConnected: false
           sendMessage: (msg) ->
             if @isConnected
               @socket.send msg
             else @queue.push msg
       )

