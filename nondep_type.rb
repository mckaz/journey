RDL.nowrap ActiveRecord::Associations::ClassMethods
RDL::Globals.info.info['ActiveRecord::Associations::ClassMethods'] = nil

Rails.application.eager_load!

MODELS = ActiveRecord::Base.descendants

class ActiveRecord_Relation
  extend RDL::Annotate
  type_params [:t], :dummy
  type :collect, "() { (t) -> u } -> Array<u>", wrap: false
  type :map, '() { (t) -> u } -> Array<u>'
  type :find_each, "() { (t) -> x } -> nil", wrap: false
  type :valid, "() -> self", wrap: false
  type :no_answer_for, "(Question) -> self", wrap: false
  type :count, "() -> Integer", wrap: false
  type :all, '() -> self', wrap: false ### kind of a silly method, always just returns self
  type :each, '() -> Enumerator<t>', wrap: false
  type :each, '() { (t) -> %any } -> Array<t>', wrap: false
  type :order, '(%any) -> self', wrap: false
  type :limit, "(Integer) -> self", wrap: false
  type :includes, "(Symbol) -> ActiveRecord_Relation", wrap: false
  type :includes, "(Symbol, Hash<Symbol, Symbol> ) -> ActiveRecord_Relation", wrap: false
  type :references, "(Symbol, *Symbol) -> self", wrap: false
  type :to_a, "() -> Array<t>", wrap: false
  type :first, "() -> t", wrap: false
  type :select, "() { (t) -> %bool } -> self", wrap: false
  type :[] , "(Integer) -> t", wrap: false
  type :group, "(Symbol or String) -> self", wrap: false
  type :where, "(String, Hash<Symbol, String>) -> self", wrap: false
  type :where, "(Hash<Symbol, x>) -> self", wrap: false
  type :find, "(Integer) -> t", wrap: false
  type :size, "() -> Integer", wrap: false
  type :build, "(?Hash<Symbol, x>) -> t", wrap: false
end

class ActiveRecord::Base
  extend RDL::Annotate
  #type 'self.where', "(Hash<Symbol, x>) -> ActiveRecord_Relation", wrap: false
  #type 'self.find', "(Integer) -> self", wrap: false
  #type 'self.find', "(Array<Integer>) -> Array<self>", wrap: false
  type :attribute_names, "() -> Array<String>", wrap: false
  type :to_json, "(?{ only: Array<String> }) -> String", wrap: false
  type :initialize, "(Hash<Symbol, x>) -> self", wrap: false
  type :initialize, "() -> self", wrap: false
  type :save, '() -> %bool', wrap: false
  type :destroy, '() -> self', wrap: false
  type :reload, "() -> %any", wrap: false
  type 'self.includes', "(*Symbol) -> ActiveRecord_Relation", wrap: false
  type 'self.includes', "(Symbol, Hash<Symbol, Symbol> ) -> ActiveRecord_Relation", wrap: false
  type :[], '(Symbol) -> Object', wrap: false
end

MODELS.each { |model|
  RDL.nowrap model
  RDL.type model, 'self.find', "(Integer) -> #{model}", wrap: false
  RDL.type model, 'self.find', "(Array<Integer>) -> Array<#{model}>", wrap: false
  RDL.type model, 'self.where', "(Hash<Symbol, x>) -> ActiveRecord_Relation<#{model}>", wrap: false
  RDL.type model, 'self.find_by', "(Hash<Symbol, x>) -> #{model}", wrap: false
  RDL.type model, 'self.create', "(Hash<Symbol, x>) -> #{model}", wrap: false
  RDL.type model, 'self.order', "(%any) -> ActiveRecord_Relation<#{model}>", wrap: false
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
    #add_assoc(assoc, a.macro, a.name)
    if a.name.to_s.pluralize == a.name.to_s ## plural association
      RDL.type model, a.name, "() -> ActiveRecord_Relation<#{a.class_name}>", wrap: false ## TODO: This actually returns an Associations CollectionProxy, which is a descendant of ActiveRecord_Relation (see below actual type). Not yet sure if this makes a difference in practice.
    #ActiveRecord_Associations_CollectionProxy<#{a.name.to_s.camelize.singularize}>'
      RDL.type model, "#{a.name}=", "(ActiveRecord_Relation<#{a.class_name}>) -> ActiveRecord_Relation<#{a.class_name}>", wrap: false
      RDL.type model, "#{a.name}=", "(Array<#{a.class_name}>) -> Array<#{a.class_name}>", wrap: false
    else
      ## association is singular, we just return an instance of associated class
      RDL.type model, a.name, "() -> #{a.class_name}", wrap: false
      RDL.type model, "#{a.name}=", "(#{a.class_name}) -> #{a.class_name}", wrap: false
    end
  }
}






### non-type checked methods
## Sequel
class SequelDB; end
class Table ; end
module Sequel; end
class SeqIdent; end
class SeqQualIdent; end
#RDL.type Dashboard, 'self.db', '() -> Sequel::Mysql2::Database', wrap: false
RDL.type SequelDB, :[], "(Symbol) -> Table", wrap: false
RDL.type SequelDB, :transaction, "() { () -> %any } -> self", wrap: false
RDL.type Sequel, 'self.qualify', "(Symbol, Symbol) -> SeqIdent", wrap: false
RDL.type Sequel, 'self.desc', '(x) -> x', wrap: false ## args will ultimately be checked by `order`
RDL.type Table, :[], "(Hash<Symbol, x>) -> Hash<Symbol, %any>", wrap: false
RDL.type Table, :where, "(Hash<Symbol, x> or String) -> Table", wrap: false
RDL.type Table, :first, "() -> Hash<Symbol, %any>", wrap: false
RDL.type Table, :first, "(Hash<Symbol, x>) -> Hash<Symbol, %any>", wrap: false
RDL.type Table, :join, "(Symbol, Hash<Symbol, x>) -> Table", wrap: false
RDL.rdl_alias :Table, :inner_join, :join
RDL.rdl_alias :Table, :left_join, :join
RDL.rdl_alias :Table, :left_outer_join, :join
RDL.type Table, :select_map, "(Symbol) -> Array<%any>", wrap: false
RDL.type Table, :any?, "() -> %bool", wrap: false
RDL.type Table, :select, "(*(Symbol or SeqIdent)) -> Table", wrap: false
RDL.type Table, :all, "() -> Array", wrap: false
RDL.type Table, :pluck, '(Symbol) -> Array<%any>', wrap: false
RDL.type Table, :server, "(Symbol) -> self", wrap: false
RDL.type Table, :count, "() -> Integer", wrap: false
RDL.type Table, :empty?, "() -> %bool", wrap: false
RDL.type Table, :update, "(Hash<Symbol, x>) -> Integer", wrap: false
RDL.type Table, :insert, "(Hash<Symbol, x>) -> Integer", wrap: false
RDL.type Table, :map, '() { (Hash<Symbol, %any>) -> x } -> Array<x>', wrap: false
RDL.type Table, :each, '() { (Hash<Symbol, %any>) -> x } -> Table', wrap: false
RDL.type Table, :import, "(Array<x>, Array<u>) -> Array<String>", wrap: false
RDL.type Table, :exclude, "(Hash<Symbol, x>) -> self", wrap: false
RDL.type Table, :exclude, "(Hash<Symbol, x>, %any) -> self", wrap: false
RDL.type Table, :order, "(*(Symbol or SeqIdent)) -> self", wrap: false


### other
RDL.type ResponsesCsvExporter, :db, "() -> SequelDB", wrap: false
RDL.type RailsSequel, 'self.connect', "() -> SequelDB", wrap: false
RDL.type ResponsesCsvExporter, :questionnaire, "() -> Questionnaire", wrap: false
RDL.type ResponsesCsvExporter, :rotate, "() -> %bool", wrap: false
RDL.type Object, :blank?, "() -> %bool", wrap: false
RDL.var_type GraphsController, :@questionnaire, "Questionnaire"
RDL.type CanCan::ControllerAdditions, :authorize!, "(Symbol, %any) -> %bool", wrap: false
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
RDL.type Gruff::Line, :initialize, '(String) -> self', wrap: false
RDL.type Gruff::Pie, :initialize, '(String) -> self', wrap: false
RDL.type Gruff::Base, :labels=, '(Hash<Integer, String>) -> Hash<Integer, String>', wrap: false
RDL.type Gruff::Base, :data, '(String, Array<Integer>) -> Hash<Integer, String>', wrap: false
RDL.type Gruff::Base, :title=, '(String) -> String', wrap: false
RDL.type GraphsController, :set_journey_theme, "(Gruff::Base) -> %any", wrap: false
RDL.type Gruff::Base, :to_blob, "() -> self", wrap: false
RDL.type ActionView::Helpers::TextHelper, :truncate, "(String) -> String", wrap: false
RDL.type CanCan::ModelAdditions::ClassMethods, :accessible_by, "(Ability) -> self", wrap: false
RDL.var_type RootController, :@new_questionnaires, "ActiveRecord_Relation<Questionnaire>"
RDL.type Devise::Controllers::Helpers, :person_signed_in?, "() -> %bool", wrap: false
RDL.type RootController, :index, "() -> %any", wrap: false
RDL.var_type RootController, :@page_title, "String"
RDL.type Devise::Controllers::Helpers, :current_person, "() -> Person", wrap: false
RDL.type QuestionnairePermission, 'self.for_person', "(Person) -> ActiveRecord_Relation<QuestionnairePermission>", wrap: false
RDL.type ActiveRecord_Relation, 'allows_anything', "() -> self", wrap: false
RDL.var_type RootController, :@my_questionnaires, "Array<Questionnaire>"
RDL.var_type RootController, :@responses, "ActiveRecord_Relation"
RDL.type ActiveSupport::Logger, :info, "(String) -> %any", wrap: false
RDL.type IllyanClient::Person, :initialize,  "(%any) -> self", wrap: false
RDL.type IllyanClient::Person, :save,  "() -> %any", wrap: false
RDL.type IllyanClient::Person, :attributes,  "() -> Hash<String, String>", wrap: false
RDL.var_type :$!, "String"
RDL.type ActiveModel::Errors, :add, "(Symbol or String, Symbol or String) -> %any", wrap: false
RDL.type ApplicationController, :current_ability, "() -> Ability", wrap: false
RDL.type ActiveRecord_Relation, :paginate, "({ page: Integer, per_page: Integer }) -> self", wrap: false
RDL.var_type QuestionnairesController, :@questionnaires, "ActiveRecord_Relation"
RDL.var_type QuestionnairesController, :@rss_url, "String"
RDL.type QuestionnairesController, :questionnaires_url, "(?{ format: String }) -> String", wrap: false
RDL.type ActionController::MimeResponds::Collector, :html, "() { () -> %any } -> %any", wrap: false
RDL.type ActionController::MimeResponds::Collector, :rss, "() { () -> %any } -> %any", wrap: false
RDL.type ActionController::MimeResponds::Collector, :xml, "() { () -> %any } -> %any", wrap: false
RDL.type ActionController::MimeResponds::Collector, :json, "() { () -> %any } -> %any", wrap: false
RDL.var_type QuestionnairesController, :@questionnaires, "ActiveRecord_Relation"
RDL.var_type QuestionnairesController, :@questionnaire, "Questionnaire"
RDL.var_type QuestionnairesController, :@rss_url, "String"
RDL.type ActiveRecord::Base, :can?, "(Symbol, ActiveRecord::Base) -> %bool", wrap: false
RDL.type ActionController::RackDelegation, :headers, "() -> Hash<String, String>", wrap: false
RDL.type Questionnaire, :to_xml, "() -> Builder::XmlMarkup", wrap: false
RDL.type :'ActionController::Instrumentation', :render, '(?String or Symbol, {content_type: ?String, layout: ?%bool or String, action: ?String or Symbol, location: ?String, nothing: ?%bool, text: ?[to_s: () -> String], status: ?Symbol, content_type: ?String, formats: ?Symbol or Array<Symbol>, locals: ?Hash<Symbol, %any>, xml: ?Builder::XmlMarkup, json: ?String, id: ?Integer, page: ?Integer }) -> Array<String>'
RDL.var_type AnswerController, :@questionnaire, "Questionnaire"
RDL.var_type AnswerController, :@resp, "Response"
RDL.var_type AnswerController, :@page, "Page"
RDL.var_type AnswerController, :@previewing, "%bool"
RDL.var_type AnswerController, :@error_messages, "Array<String>"
RDL.var_type AnswerController, :@all_responses, "Array<Response>"
RDL.var_type AnswerController, :@responses, "Array<Response>"
RDL.type ActionController::Metal, :session, "() -> Hash<String, Integer>", wrap: false
RDL.type AnswerController, :answer_given, "(Integer) -> %bool", wrap: false
RDL.type AnswerController, :params, "() -> { id: Integer, question: Hash<String, String>, current_page: Integer, commit: String, page: Integer }", wrap: false
RDL.type :'ActionController::Instrumentation', :redirect_to, '({id: ?Integer, controller: ?String, action: ?String, notice: ?String, alert: ?String, current_page: ?Integer, page: ?Integer }) -> String'
RDL.type AnswerController, :validate_answers, "(Response, Page) -> Array<String>", wrap: false
RDL.type ActiveRecord_Relation, :notify_on_response_submit, "() -> self", wrap: false
RDL.type Object, :try, "(Symbol) -> Object", wrap: false
RDL.type Object, :present?, "() -> %bool", wrap: false
RDL.type NotificationMailer, 'self.response_submitted', "(Response, Person) -> ActionMailer::MessageDelivery", wrap: false
RDL.type ActionMailer::MessageDelivery, :deliver_later, "() -> %any", wrap: false
RDL.type ActionController::Base, :flash, "() -> Hash<Symbol, String or Array<String>>", wrap: false
RDL.var_type ResponsesController, :@questionnaire, "Questionnaire"
RDL.var_type ResponsesController, :@email_notification, "EmailNotification"


### type checked methods

RDL.type ResponsesCsvExporter, :answers_table, "() -> Table", wrap: false, typecheck: :later # 1
RDL.type ResponsesCsvExporter, :each_row, "() {(%any) -> %any } -> %any", wrap: false, typecheck: :later # 10
RDL.type GraphsController, :aggregate_questions, "(Array<Integer> or Integer) -> Hash<Integer, Hash<String, Integer>>", wrap: false, typecheck: :later # 7
RDL.type GraphsController, :line, "() -> Array<String>", wrap: false, typecheck: :later # 4
RDL.type GraphsController, :pie, "() -> Array<String>", wrap: false, typecheck: :later # 2
RDL.type RootController, :get_new_questionnaires, "() -> ActiveRecord_Relation<Questionnaire>", wrap: false, typecheck: :later # 0
RDL.type RootController, :dashboard, "() -> %any", wrap: false, typecheck: :later # 2
RDL.type Answer, 'self.find_answer', "(Response, Question) -> Answer", wrap: false, typecheck: :later # 0
RDL.type QuestionnairePermission, :email=, "(String) -> %any", wrap: false, typecheck: :later # 1
## Bug below???
#RDL.type Response, :verify_answers_for_page, "(Page) -> Float", wrap: false, typecheck: :later
RDL.type Response, :answer_for_question, "(Question) -> Answer", wrap: false, typecheck: :later # 0
RDL.type QuestionnairesController, :index, "() -> Array<String> or String", wrap: false, typecheck: :later # 8
RDL.type QuestionnairesController, :show, "() -> Array<String> or String", wrap: false, typecheck: :later # 2
RDL.type AnswerController, :get_questionnaire, "() -> Questionnaire", wrap: false, typecheck: :later # 1
RDL.type AnswerController, :save_answers, "() -> String", wrap: false, typecheck: :later # 9
RDL.type AnswerController, :preview, "() -> Array<String>", wrap: false, typecheck: :later # 3
RDL.type AnswerController, :questionnaire_closed, "() -> Questionnaire", wrap: false, typecheck: :later # 1
RDL.type AnswerController, :prompt, "() -> Array<Response>", wrap: false, typecheck: :later # 2
## BUG below??
#RDL.type AnswerController, :index, "() -> Float", wrap: false, typecheck: :later
RDL.type AnswerController, :resume, "() -> String", wrap: false, typecheck: :later # 2
RDL.type ResponsesController, :get_email_notification, "() -> EmailNotification", wrap: false, typecheck: :later # 0


# 13 in the original

# 55



RDL.do_typecheck :later
