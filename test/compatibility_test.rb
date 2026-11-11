ENV['RAILS_ENV'] ||= 'test'
require 'rails/all'
require ENV.fetch('ASSET_PIPELINE', 'sprockets-rails') == 'propshaft' ? 'propshaft' : 'sprockets/railtie'
require 'trestle/active_storage'
require 'minitest/autorun'

class CompatibilityApp < Rails::Application
  config.root = File.expand_path('dummy', __dir__)
  config.eager_load = false
  config.secret_key_base = 'test-secret-key-base-' * 4
end

class CompatibilityTest < Minitest::Test
  def test_engine_boots_with_configured_asset_pipeline
    CompatibilityApp.initialize!

    assert CompatibilityApp.initialized?
    assert_includes Trestle::ResourceController.ancestors, Trestle::ActiveStorage::ControllerConcern
    assert_includes Trestle::Resource.ancestors, Trestle::ActiveStorage::Resource
  end
end

class AttachmentControllerTest < Minitest::Test
  class Controller < ActionController::Base
    include Trestle::ActiveStorage::ControllerConcern
    attr_accessor :admin, :instance
  end

  class Attachment < Struct.new(:blob_id, :purged)
    def purge
      self.purged = true
    end
  end

  class Document < Struct.new(:files)
  end

  class Admin < Struct.new(:object)
    def active_storage_fields
      [:files]
    end

    def find_instance(_params)
      object
    end
  end

  def test_purges_only_the_selected_integer_attachment
    verify_attachment_deletion(123, '123')
  end

  def test_purges_only_the_selected_uuid_attachment
    verify_attachment_deletion('550e8400-e29b-41d4-a716-446655440000', '550e8400e29b41d4a716446655440000')
  end

  private

  def verify_attachment_deletion(id, field_suffix)
    selected = Attachment.new(id)
    other = Attachment.new(456)
    document = Document.new([selected, other])
    controller = Controller.new
    controller.admin = Admin.new(document)
    controller.params = {}
    controller.send(:define_attachment_accessors)
    document.public_send("delete_files_#{field_suffix}=", '1')
    controller.send(:purge_attachments)
    assert selected.purged
    refute other.purged
  end
end
