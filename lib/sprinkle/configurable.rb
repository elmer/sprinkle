module Sprinkle
  #--
  # TODO: Possible documentation?
  #++
  module Configurable #:nodoc:
    attr_accessor :delivery
    
    def defaults(deployment)
      defaults = deployment.defaults[self.class.name.split(/::/).last.downcase.to_sym]
      self.instance_eval(&defaults) if defaults
      @delivery = deployment.style
    end
    
    def assert_delivery
      raise 'Unknown command delivery target' unless @delivery
    end
    
    def method_missing(sym, *args, &block)
      unless args.empty? # mutate if not set
        @options ||= {}
        # There's a difference for a = *[42] between Ruby 1.8 and 1.9:
        # ruby 1.9.2dev (2010-02-22 trunk 26730): => [42]
        # ruby 1.8.7 (2008-08-11 patchlevel 72) : => 42
        # We want the 1.8 behaviour, so we don't just use *args here.
        # The 1.9 behaviour seems to be on purpose (http://redmine.ruby-lang.org/issues/show/2422)
        # FIXME Find a nicer way? Remove these comments.
        @options[sym] = args.length == 1 ? args.first : args unless @options[sym]
      end
      
      @options[sym] || @package.send(sym, *args, &block) # try the parents options if unknown
    end
    
    def option?(sym)
      !@options[sym].nil?
    end
  end
end