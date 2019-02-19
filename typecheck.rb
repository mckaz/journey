Rails.application.eager_load! ## load Rails app

## File below includes all the DB/Rails method annotations used during type checking. This time, they don't include type-level computations
require './db_types.rb'


### type checked methods

RDL.type ResponsesCsvExporter, :answers_table, "() -> Table", wrap: false, typecheck: :later 
RDL.type ResponsesCsvExporter, :each_row, "() {(%any) -> %any } -> %any", wrap: false, typecheck: :later 
RDL.type GraphsController, :aggregate_questions, "(Array<Integer> or Integer) -> Hash<Integer, Hash<String, Integer>>", wrap: false, typecheck: :later 
RDL.type GraphsController, :line, "() -> Array<String>", wrap: false, typecheck: :later
RDL.type GraphsController, :pie, "() -> Array<String>", wrap: false, typecheck: :later 
RDL.type RootController, :get_new_questionnaires, "() -> ActiveRecord_Relation<Questionnaire>", wrap: false, typecheck: :later 
RDL.type RootController, :dashboard, "() -> %any", wrap: false, typecheck: :later 
RDL.type Answer, 'self.find_answer', "(Response, Question) -> Answer", wrap: false, typecheck: :later 
RDL.type QuestionnairePermission, :email=, "(String) -> %any", wrap: false, typecheck: :later
RDL.type Response, :verify_answers_for_page, "(Page) -> Array<Question>", wrap: false, typecheck: :later
RDL.type Response, :answer_for_question, "(Question) -> Answer", wrap: false, typecheck: :later 
RDL.type QuestionnairesController, :index, "() -> Array<String> or String", wrap: false, typecheck: :later
RDL.type QuestionnairesController, :show, "() -> Array<String> or String", wrap: false, typecheck: :later 
RDL.type AnswerController, :get_questionnaire, "() -> Questionnaire", wrap: false, typecheck: :later
RDL.type AnswerController, :save_answers, "() -> String", wrap: false, typecheck: :later 
RDL.type AnswerController, :preview, "() -> Array<String>", wrap: false, typecheck: :later 
RDL.type AnswerController, :questionnaire_closed, "() -> Questionnaire", wrap: false, typecheck: :later
RDL.type AnswerController, :prompt, "() -> Array<Response>", wrap: false, typecheck: :later
RDL.type AnswerController, :index, "() -> %any", wrap: false, typecheck: :later
RDL.type AnswerController, :resume, "() -> String", wrap: false, typecheck: :later
RDL.type ResponsesController, :get_email_notification, "() -> EmailNotification", wrap: false, typecheck: :later 


### variable and non-checked method types
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



## set config to not use comp types.
RDL::Config.instance.use_dep_types = false
## Call `do_typecheck` to type check methods
RDL.do_typecheck :later
