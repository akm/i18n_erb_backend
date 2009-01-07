# -*- coding: utf-8 -*-
require File.join(File.dirname(__FILE__), 'test_helper')

class InsertTextTest < Test::Unit::TestCase
  
  def test_insert_text
    I18n
    I18n::Backend
    I18n.backend = I18n::Backend::Erb.new
    locale_files = Dir[ File.join(File.dirname(__FILE__), 'locales', '*.{yml}') ]
    I18n.load_path += locale_files
    
    I18n.locale = nil
    assert_equal :en, I18n.locale
    assert_equal "Hello", I18n.t(:hello)
    assert_equal "must be splitted by comma", I18n.t(:'activerecord.errors.messages.E00001')
    assert_equal "User", I18n.t(:'activerecord.models.user')
    assert_equal "Product", I18n.t(:'activerecord.models.product')
    assert_equal "Name", I18n.t(:'activerecord.attributes.user.name')
    assert_equal "Product Name", I18n.t(:'activerecord.attributes.product.name')
    assert_equal "Price", I18n.t(:'activerecord.attributes.product.price')
    
    I18n.locale = 'en'
    assert_equal 'en', I18n.locale
    assert_equal "Hello", I18n.t(:hello)
    assert_equal "must be splitted by comma", I18n.t(:'activerecord.errors.messages.E00001')
    assert_equal "User", I18n.t(:'activerecord.models.user')
    assert_equal "Product", I18n.t(:'activerecord.models.product')
    assert_equal "Name", I18n.t(:'activerecord.attributes.user.name')
    assert_equal "Product Name", I18n.t(:'activerecord.attributes.product.name')
    assert_equal "Price", I18n.t(:'activerecord.attributes.product.price')
    
    I18n.locale = 'ja'
    assert_equal 'ja', I18n.locale
    assert_equal "こんにちわ", I18n.t(:hello)
    assert_equal "はカンマ区切りで入力してください", I18n.t(:'activerecord.errors.messages.E00001')
    assert_equal "ユーザー", I18n.t(:'activerecord.models.user')
    assert_equal "商品", I18n.t(:'activerecord.models.product')
    assert_equal "名前", I18n.t(:'activerecord.attributes.user.name')
    assert_equal "商品名", I18n.t(:'activerecord.attributes.product.name')
    assert_equal "価格", I18n.t(:'activerecord.attributes.product.price')
  end
  
  
  def test_to_properties
    assert_equal(
      File.open(File.join(File.dirname(__FILE__), 'locales', 'yaml2prop_ja.properties')).read,
      YAML.to_properties(File.join(File.dirname(__FILE__), 'locales', 'yaml2prop_ja.yml'))
    )
  end
  
  def test_from_properties
    assert_equal(
      File.open(File.join(File.dirname(__FILE__), 'locales', 'yaml2prop_ja.yml')).read,
      YAML.from_properties(File.join(File.dirname(__FILE__), 'locales', 'yaml2prop_ja.properties'))
    )
  end
  
end
