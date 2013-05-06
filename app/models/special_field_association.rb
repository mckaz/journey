class SpecialFieldAssociation < ActiveRecord::Base
  validates_inclusion_of :purpose, :in => Questionnaire.special_field_purposes
  belongs_to :question, :foreign_key => :question_id
  belongs_to :questionnaire, :foreign_key => :questionnaire_id
end
