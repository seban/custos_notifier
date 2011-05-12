module CustosNotifier
  module Rails
    module ActionControllerCatcher

      private


      # Override standard exception handling behaviour.
      def rescue_action_in_public(exception)
        CustosNotifier.notify(exception, :request => request)
        super
      end

    end
  end
end