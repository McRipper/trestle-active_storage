require 'rails/all'
require 'trestle/active_storage'
require 'minitest/autorun'

class CompatibilityApp < Rails::Application
  config.eager_load = false
  config.secret_key_base = 'test-secret-key-base-' * 4
end

class CompatibilityTest < Minitest::Test
  def test_engine_boots_without_sprockets
    CompatibilityApp.initialize!

    assert CompatibilityApp.initialized?
    assert_includes Trestle::ResourceController.ancestors, Trestle::ActiveStorage::ControllerConcern
    assert_includes Trestle::Resource.ancestors, Trestle::ActiveStorage::Resource
  end
end
