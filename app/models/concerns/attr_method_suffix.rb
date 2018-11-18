# frozen_string_literal: true

module AttrMethodSuffix
  extend ActiveSupport::Concern

  included do
    attribute_method_suffix "_text"
  end

  private
    def attribute_text(attr_name)
      return unless [true, false].include?(send(attr_name))

      send(attr_name) ? I18n.t("action.switch_yes") : I18n.t("action.switch_no")
    end
end
