# frozen_string_literal: true

module Admin::ArticlesHelper
  def full_atricle_tags
    Tag.all.select("permalink, name").map do |e|
      [e.name, e.permalink]
    end
  end

  def atricle_categories
    Category.all.select("id, name, permalink").map do |e|
      [e.name, e.id, { "data-type" => e.permalink }]
    end
  end
end
