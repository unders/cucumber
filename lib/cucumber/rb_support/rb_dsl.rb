require 'cucumber/rb_support/rb_hook'

module Cucumber
  module RbSupport
    # This module defines the methods you can use to define pure Ruby
    # Step Definitions and Hooks. This module is mixed into the toplevel
    # object.
    module RbDsl
      class << self
        attr_accessor :step_mother, :rb_language
        
        def alias_adverb(adverb)
          alias_method adverb, :register_rb_step_definition
        end
      end

      # Registers any number of +world_modules+ (Ruby Modules) and/or a Proc.
      # The +proc+ will be executed once before each scenario to create an
      # Object that the scenario's steps will run within. Any +world_modules+
      # will be mixed into this Object (via Object#extend).
      #
      # This method is typically called from one or more Ruby scripts under 
      # <tt>features/support</tt>. You can call this method as many times as you 
      # like (to register more modules), but if you try to register more than 
      # one Proc you will get an error.
      #
      # Cucumber will not yield anything to the +proc+. Examples:
      #
      #    World do
      #      MyClass.new
      #    end
      #
      #    World(MyModule)
      #
      def World(*world_modules, &proc)
        RbDsl.rb_language.build_world_factory(*world_modules, &proc)
      end

      # Registers a proc that will run before each Scenario. You can register as 
      # as you want (typically from ruby scripts under <tt>support/hooks.rb</tt>).
      def Before(*tag_names, &proc)
        RbDsl.step_mother.register_hook(:before, RbHook.new(RbDsl.rb_language, tag_names, proc))
      end

      # Registers a proc that will run after each Scenario. You can register as 
      # as you want (typically from ruby scripts under <tt>support/hooks.rb</tt>).
      def After(*tag_names, &proc)
        RbDsl.step_mother.register_hook(:after, RbHook.new(RbDsl.rb_language, tag_names, proc))
      end

      # Registers a proc that will run after each Step. You can register as 
      # as you want (typically from ruby scripts under <tt>support/hooks.rb</tt>).
      def AfterStep(*tag_names, &proc)
        RbDsl.step_mother.register_hook(:after_step, RbHook.new(RbDsl.rb_language, tag_names, proc))
      end

      # Registers a new Ruby StepDefinition. This method is aliased
      # to <tt>Given</tt>, <tt>When</tt> and <tt>Then</tt>, and
      # also to the i18n translations whenever a feature of a
      # new language is loaded.
      #
      # The +&proc+ gets executed in the context of a <tt>World</tt>
      # object, which is defined by #World. A new <tt>World</tt>
      # object is created for each scenario and is shared across
      # step definitions within that scenario.
      def register_rb_step_definition(regexp, &proc)
        RbDsl.step_mother.register_step_definition(RbStepDefinition.new(RbDsl.rb_language, regexp, &proc))
      end
    end
  end
end

extend(Cucumber::RbSupport::RbDsl)