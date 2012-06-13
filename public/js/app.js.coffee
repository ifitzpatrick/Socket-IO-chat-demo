angular.module('chat', [])
       .controller('mainCtrl', ($scope, Messenger) ->
         $scope.messages = []
         $scope.newMessage = ''
         $scope.user = ''
         $scope.isConnected = false
         $scope.addMessage = (message) ->
           $scope.messages.push message

         queue = []
         $scope.formatMessage = (message) ->
           if $scope.user.length then "#{$scope.user}: #{message}" else message

         chatMessenger = new Messenger
           route: '/'
           scope: $scope
           onMessage: (msg) ->
             $scope.addMessage msg
           onConnect: ->
             $scope.isConnected = true

         $scope.sendMessage = (message) ->
           $scope.newMessage = ''
           chatMessenger.sendMessage $scope.formatMessage message

         $scope.connectionMessage = ->
           if $scope.isConnected
             "Connected"
           else "Connecting..."


       ).directive('pressEnter', ->
         (scope, element, attrs) ->
           element.keydown (evt) ->
             if evt.which is 13
               scope.$apply attrs['pressEnter']

       ).factory('io', -> io
       ).factory('Messenger', (io) ->
         class
           constructor: (props) ->
             @socket = io.connect props.route
             @scope = props.scope

             @socket.on 'connect', =>
               @isConnected = true
               if props.onConnect?
                 @scope.$apply ->
                   props.onConnect()

               for message in @queue
                 @sendMessage message

               if props.onMessage?
                 @socket.on 'message', (msg) =>
                   @scope.$apply ->
                     props.onMessage msg

           queue: []
           isConnected: false
           sendMessage: (msg) ->
             if @isConnected
               @socket.send msg
             else @queue.push msg
       )

