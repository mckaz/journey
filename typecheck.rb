require_relative 'db_types.rb'
require_relative 'ar_types.rb'

RDL.nowrap ActiveRecord::Associations::ClassMethods

RDL.config { |config|
  config.promote_widen = true
}

module RDL::Globals
  # Map from table names (symbols) to their schema types, which should be a Table type
  @seq_db_schema = {}
  @ar_db_schema = {}
end

class << RDL::Globals
  attr_accessor :seq_db_schema
  attr_accessor :ar_db_schema
end
=begin
class ActiveRecord_Relation
  ## In practice, this is actually a private class nested within
  ## each ActiveRecord::Base, e.g. Person::ActiveRecord_Relation.
  ## Using this class just for type checking.
  extend RDL::Annotate
  include ActiveRecord::QueryMethods
  include ActiveRecord::FinderMethods
  include ActiveRecord::Calculations
  include ActiveRecord::Delegation

  type_params [:base], :dummy
end
=end
RDL::Globals.info.info['ActiveRecord::Associations::ClassMethods'] = nil

puts "GOT HERE"

def add_assoc(hash, aname, aklass)
  kl_type = RDL::Type::SingletonType.new(aklass)
  if hash[aname]
    hash[aname] = RDL::Type::UnionType.new(hash[aname], kl_type)
  else
    hash[aname] = kl_type unless hash[aname]
  end
  hash
end


Rails.application.eager_load!
MODELS = ActiveRecord::Base.descendants
=begin
MODELS = ActiveRecord::Base.descendants.each { |m|
  begin
    m.send(:load_schema) unless m.abstract_class?
  rescue
    puts "#{m} didn't work"
  end 
}
=end
MODELS.each { |model|
  RDL.nowrap model
  s1 = {}
  model.columns_hash.each { |k, v| t_name = v.type.to_s.camelize
    if t_name == "Boolean"
      t_name = "%bool"
      s1[k] = RDL::Globals.types[:bool]
    elsif t_name == "Datetime"
      t_name = "DateTime or Time"
      s1[k] = RDL::Type::UnionType.new(RDL::Type::NominalType.new(Time), RDL::Type::NominalType.new(DateTime))
    elsif t_name == "Text"
      ## difference between `text` and `string` is in the SQL types they're mapped to, not in Ruby types
      t_name = "String"
      s1[k] = RDL::Globals.types[:string]
    else
      s1[k] = RDL::Type::NominalType.new(t_name)
    end
    RDL.type model, (k+"=").to_sym, "(#{t_name}) -> #{t_name}", wrap: false ## create method type for column setter
    RDL.type model, (k).to_sym, "() -> #{t_name}", wrap: false ## create method type for column getter
  }
  s2 = s1.transform_keys { |k| k.to_sym }
  assoc = {}

  model.reflect_on_all_associations.each { |a|
    add_assoc(assoc, a.macro, a.name)
    if a.name.to_s.pluralize == a.name.to_s ## plural association
      RDL.type model, a.name, "() -> ActiveRecord_Relation<#{a.class_name}>", wrap: false ## TODO: This actually returns an Associations CollectionProxy, which is a descendant of ActiveRecord_Relation (see below actual type). Not yet sure if this makes a difference in practice.
    #ActiveRecord_Associations_CollectionProxy<#{a.name.to_s.camelize.singularize}>'
      RDL.type model, "#{a.name}=", "(ActiveRecord_Relation<#{a.class_name}> or Array<#{a.class_name}>) -> ``targs[0]``", wrap: false
    else
      ## association is singular, we just return an instance of associated class
      RDL.type model, a.name, "() -> #{a.class_name}", wrap: false
      RDL.type model, "#{a.name}=", "(#{a.class_name}) -> #{a.class_name}", wrap: false
    end
  }
  s2[:__associations] = RDL::Type::FiniteHashType.new(assoc, nil)
  base_name = model.to_s
  base_type = RDL::Type::NominalType.new(model.to_s)
  hash_type = RDL::Type::FiniteHashType.new(s2, nil)
  schema = RDL::Type::GenericType.new(base_type, hash_type)
  RDL::Globals.ar_db_schema[base_name.to_sym] = schema
}

DB = RailsSequel.connect

def gen_schema(db)
  db.tables.each { |table|
    hash_str = "{ "
    kl_name = table.to_s.camelize.singularize
    db.schema(table).each { |col|
      hash_str << "#{col[0]}: "
      typ = col[1][:type].to_s.camelize
      if typ == "Datetime"
        typ = "DateTime or Time" ## Sequel accepts both
      elsif typ == "Boolean"
        typ = "%bool"
      elsif typ == "Text"
        typ = "String"
      end
      hash_str << "#{typ},"
      RDL.type kl_name, col[0], "() -> #{typ}", wrap: false
      RDL.type kl_name, "#{col[0]}=", "(#{typ}) -> #{typ}", wrap: false
    }
    hash_str.chomp!(",") << " }"
    RDL::Globals.seq_db_schema[table] = RDL::Globals.parser.scan_str "#T #{hash_str}"
  }
end

gen_schema(DB)


#RDL::Globals.db_schema.each { |k, v| puts v if k == :question_options }

### NON-CHECKED METHODS
RDL.type ResponsesCsvExporter, :db, "() -> SequelDB", wrap: false
RDL.type RailsSequel, 'self.connect', "() -> SequelDB", wrap: false
RDL.type ResponsesCsvExporter, :questionnaire, "() -> Questionnaire", wrap: false
RDL.type ResponsesCsvExporter, :rotate, "() -> %bool", wrap: false
RDL.type Object, :blank?, "() -> %bool", wrap: false
#RDL.type ActiveRecord::Base, 'self.where', "(``Table.where_arg_type(RDL::Type::GenericType.new(RDL::Type::NominalType.new(Table), RDL::Globals.db_schema[trec.val.to_s.underscore.pluralize.to_sym]), targs)``) -> ``RDL::Type::GenericType.new(RDL::Type::NominalType.new(ActiveRecord_Relation), RDL::Type::NominalType.new(trec.val))``", wrap: false ## hacky way to handle ActiveRecord in Sequel context
RDL.var_type GraphsController, :@questionnaire, "Questionnaire"
RDL.var_type GraphsController, :@questions, "ActiveRecord_Relation<Question>"
RDL.var_type GraphsController, :@question, "Question"
RDL.var_type GraphsController, :@counts, "Hash<Integer, Hash<String, Integer>>"
RDL.var_type GraphsController, :@min, "Integer"
RDL.var_type GraphsController, :@max, "Integer"
RDL.var_type GraphsController, :@geom, "String"
RDL.var_type GraphsController, :@graph, "Gruff::Base"
RDL.var_type GraphsController, :@labels, "Hash<Integer, String>"
RDL.var_type GraphsController, :@series, "Hash<Question, Array<Integer>>"
RDL.var_type GraphsController, :@answercounts, "Hash<String, Integer>"
RDL.type ActiveRecord_Relation, :valid, "() -> ``if trec.params[0].name == 'Response' then trec else raise 'unexpected param type' end ``", wrap: false
RDL.type ActiveRecord_Relation, :no_answer_for, "(``if trec.params[0].name == 'Response' then RDL::Type::NominalType.new(Question) else raise 'unexpected param type' end``) -> self", wrap: false
RDL.type CanCan::ControllerAdditions, :authorize!, "(Symbol, %any) -> %bool", wrap: false
RDL.type GraphsController, :params, "() -> { question_ids: Array<Integer>, question_id: Integer }", wrap: false
RDL.type Question, :min, '() -> Integer', wrap: false
RDL.type Question, :max, '() -> Integer', wrap: false
RDL.type Gruff::Line, :initialize, '(String) -> self', wrap: false
RDL.type Gruff::Pie, :initialize, '(String) -> self', wrap: false
RDL.type Gruff::Base, :labels=, '(Hash<Integer, String>) -> Hash<Integer, String>', wrap: false
RDL.type Gruff::Base, :data, '(String, Array<Integer>) -> Hash<Integer, String>', wrap: false
RDL.type Gruff::Base, :title=, '(String) -> String', wrap: false
RDL.type GraphsController, :set_journey_theme, "(Gruff::Base) -> %any", wrap: false
RDL.type Gruff::Base, :to_blob, "() -> self", wrap: false
RDL.type ActionView::Helpers::TextHelper, :truncate, "(String) -> String", wrap: false
RDL.var_type RootController, :@new_questionnaires, "ActiveRecord_Relation<Questionnaire>"
RDL.var_type RootController, :@page_title, "String"
RDL.var_type RootController, :@my_questionnaires, "Array<Questionnaire>"
RDL.var_type RootController, :@responses, "ActiveRecord_Relation<JoinTable<Response, Questionnaire>>"
RDL.type Devise::Controllers::Helpers, :person_signed_in?, "() -> %bool", wrap: false
RDL.type Devise::Controllers::Helpers, :current_person, "() -> Person", wrap: false
RDL.type RootController, :index, "() -> %any", wrap: false
RDL.type QuestionnairePermission, 'self.for_person', "(Person) -> ActiveRecord_Relation<QuestionnairePermission>", wrap: false
RDL.type ActiveRecord_Relation, 'allows_anything', "() -> ``if trec.params[0].name == 'QuestionnairePermission' then trec else raise 'unexpected type' end``", wrap: false
RDL.type ActiveSupport::Logger, :info, "(String) -> %any", wrap: false
RDL.type IllyanClient::Person, :initialize,  "(%any) -> self", wrap: false
RDL.type IllyanClient::Person, :save,  "() -> %any", wrap: false
RDL.type IllyanClient::Person, :attributes,  "() -> Hash<String, String>", wrap: false
RDL.var_type :$!, "String"
RDL.type ActiveModel::Errors, :add, "(Symbol or String, Symbol or String) -> %any", wrap: false
RDL.type QuestionnairesController, :params, "() -> { title: String, tag: String, page: Integer, id: String, attributes: Array<String> }", wrap: false
RDL.type ApplicationController, :current_ability, "() -> Ability", wrap: false
RDL.type ActiveRecord_Relation, :paginate, "({ page: Integer, per_page: Integer }) -> self", wrap: false
RDL.var_type QuestionnairesController, :@questionnaires, "ActiveRecord_Relation<JoinTable<Questionnaire, QuestionnairePermission or Person or Tag>>"
RDL.var_type QuestionnairesController, :@questionnaire, "Questionnaire"
RDL.var_type QuestionnairesController, :@rss_url, "String"
RDL.type QuestionnairesController, :questionnaires_url, "(?{ format: String }) -> String", wrap: false
RDL.type ActionController::MimeResponds::Collector, :html, "() { () -> %any } -> %any", wrap: false
RDL.type ActionController::MimeResponds::Collector, :rss, "() { () -> %any } -> %any", wrap: false
RDL.type ActionController::MimeResponds::Collector, :xml, "() { () -> %any } -> %any", wrap: false
RDL.type ActionController::MimeResponds::Collector, :json, "() { () -> %any } -> %any", wrap: false
RDL.type ActiveRecord::Base, :can?, "(Symbol, ActiveRecord::Base) -> %bool", wrap: false
RDL.type ActionController::RackDelegation, :headers, "() -> Hash<String, String>", wrap: false
RDL.type Questionnaire, :to_xml, "() -> Builder::XmlMarkup", wrap: false
RDL.type :'ActionController::Instrumentation', :render, '(?String or Symbol, {content_type: ?String, layout: ?%bool or String, action: ?String or Symbol, location: ?String, nothing: ?%bool, text: ?[to_s: () -> String], status: ?Symbol, content_type: ?String, formats: ?Symbol or Array<Symbol>, locals: ?Hash<Symbol, %any>, xml: ?Builder::XmlMarkup, json: ?String, id: ?Integer, page: ?Integer }) -> Array<String>'
RDL.type AnswerController, :params, "() -> { id: String, question: Hash<String, String>, current_page: Integer, commit: String, page: Integer }", wrap: false
RDL.var_type AnswerController, :@questionnaire, "Questionnaire"
RDL.var_type AnswerController, :@resp, "Response"
RDL.var_type AnswerController, :@page, "Page"
RDL.var_type AnswerController, :@previewing, "%bool"
RDL.var_type AnswerController, :@error_messages, "Array<String>"
RDL.var_type AnswerController, :@all_responses, "Array<Response>"
RDL.var_type AnswerController, :@responses, "Array<Response>"
RDL.type ActionController::Metal, :session, "() -> Hash<String, Integer>", wrap: false
RDL.type AnswerController, :answer_given, "(Integer) -> %bool", wrap: false
RDL.type :'ActionController::Instrumentation', :redirect_to, '({id: ?Integer, controller: ?String, action: ?String, notice: ?String, alert: ?String, current_page: ?Integer, page: ?Integer }) -> String'
RDL.type AnswerController, :validate_answers, "(Response, Page) -> Array<String>", wrap: false
RDL.type ActiveRecord_Relation, :notify_on_response_submit, "() -> ``if trec.params[0].name == 'EmailNotification' then trec else raise 'unexpected type' end``", wrap: false
RDL.type NotificationMailer, 'self.response_submitted', "(Response, Person) -> ActionMailer::MessageDelivery", wrap: false
RDL.type ActionMailer::MessageDelivery, :deliver_later, "() -> %any", wrap: false
RDL.type ActionController::Base, :flash, "() -> Hash<Symbol, String or Array<String>>", wrap: false
RDL.var_type ResponsesController, :@questionnaire, "Questionnaire"
RDL.var_type ResponsesController, :@email_notification, "EmailNotification"
RDL.type CanCan::ModelAdditions::ClassMethods, :accessible_by, "(Ability) -> self", wrap: false


### TYPE CHECKED METHODS
### Note: there is a bit of a mix between Sequel and ActiveRecord. The classifications below broadly speak to what category the methods mostly fall under.
###-----------Sequel Methods----------------###
RDL.type ResponsesCsvExporter, :answers_table, "() -> Table<{ id: Integer, response_id: Integer, question_id: Integer, value: String, created_at: Time or DateTime, updated_at: Time or DateTime, questionnaire_id: Integer, saved_page: Integer, submitted: false or true, person_id: Integer, submitted_at: Time or DateTime, notes: String, type: String, position: Integer, caption: String, required: false or true, min: Integer, max: Integer, step: Integer, page_id: Integer, default_answer: String, layout: String, radio_layout: String, title: String, option: String, output_value: String, __all_joined: :questions or :pages or :responses or :answers or :question_options, __last_joined: :question_options, __selected: nil, __orm: false }>", wrap: false, typecheck: :later
RDL.type ResponsesCsvExporter, :each_row, "() {(%any) -> %any } -> %any", wrap: false, typecheck: :later
RDL.type GraphsController, :aggregate_questions, "(Array<Integer> or Integer) -> Hash<Integer, Hash<String, Integer>>", wrap: false, typecheck: :later
RDL.type GraphsController, :line, "() -> Array<String>", wrap: false, typecheck: :later
RDL.type GraphsController, :pie, "() -> Array<String>", wrap: false, typecheck: :later
RDL.type RootController, :get_new_questionnaires, "() -> ActiveRecord_Relation<Questionnaire>", wrap: false, typecheck: :later
RDL.type RootController, :dashboard, "() -> %any", wrap: false, typecheck: :later
RDL.type Answer, 'self.find_answer', "(Response, Question) -> Answer", wrap: false, typecheck: :later
RDL.type QuestionnairePermission, :email=, "(String) -> %any", wrap: false, typecheck: :later
## Bug below???
#RDL.type Response, :verify_answers_for_page, "(Page) -> Float", wrap: false, typecheck: :later
RDL.type Response, :answer_for_question, "(Question) -> Answer", wrap: false, typecheck: :later
RDL.type QuestionnairesController, :index, "() -> Array<String> or String", wrap: false, typecheck: :later
RDL.type QuestionnairesController, :show, "() -> Array<String> or String", wrap: false, typecheck: :later
RDL.type AnswerController, :get_questionnaire, "() -> Questionnaire", wrap: false, typecheck: :later
RDL.type AnswerController, :save_answers, "() -> String", wrap: false, typecheck: :later
RDL.type AnswerController, :preview, "() -> Array<String>", wrap: false, typecheck: :later
RDL.type AnswerController, :questionnaire_closed, "() -> Questionnaire", wrap: false, typecheck: :later
RDL.type AnswerController, :prompt, "() -> Array<Response>", wrap: false, typecheck: :later
## BUG below??
#RDL.type AnswerController, :index, "() -> Float", wrap: false, typecheck: :later
RDL.type AnswerController, :resume, "() -> String", wrap: false, typecheck: :later
RDL.type ResponsesController, :get_email_notification, "() -> EmailNotification", wrap: false, typecheck: :later

RDL.do_typecheck :later

