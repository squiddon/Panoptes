module Translatable
  extend ActiveSupport::Concern

  included do
    validates :primary_language, format: {with: /\A[a-z]{2}(\z|-[A-z]{2})/}
    has_many content_association
  end

  module ClassMethods
    def content_association
      "#{model_name.singular}_contents".to_sym
    end

    def content_model
      "#{name}Content".constantize
    end
  end

  def content_for(languages, fields)
    language = best_match_for(languages)
    content_association.select(*fields).where(language: language).first
  end

  def available_languages
    content_association.select('language').map(&:language).map(&:downcase)
  end

  def content_association
    @content_associattion ||= send(self.class.content_association)
  end

  private

  def best_match_for(languages)
    languages = languages.flat_map do |lang|
      if lang.length == 2
        lang
      else
        [lang, lang.split('-').first]
      end
    end
    (languages & available_languages).first || primary_language
  end
end