module Trestle
  module ActiveStorage
    class Engine < Rails::Engine
      # Propshaft serves engine assets directly; only Sprockets needs precompile entries.
      initializer 'trestle.active_storage.assets' do
        if defined?(Sprockets)
          config.assets.precompile << 'activestorage.js' << 'trestle/active_storage_fields.js'
        end
      end

      config.to_prepare do
        Trestle::ResourceController.send(:include, Trestle::ActiveStorage::ControllerConcern)
      end

      initializer :extensions do
        Trestle::Resource.send(:include, Trestle::ActiveStorage::Resource)
        Trestle::Resource::Builder.send(:include, Trestle::ActiveStorage::Builder)
      end
    end
  end
end
