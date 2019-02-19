require_relative '../db-types/sequel/db_types.rb'
require_relative '../db-types/active-record/db_types.rb'
#require_relative '../db_type_check/sequel_types.rb'
#require_relative '../db_type_check/ar_types.rb'

## file required below builds the schema model used during type checking
  require_relative './build_schema.rb'



puts "Type checking methods from Journey..."


### Annotations for type checked methods.
RDL.type ResponsesCsvExporter, :answers_table, "() -> Table<{ id: Integer, response_id: Integer, question_id: Integer, value: String, created_at: Time or DateTime, updated_at: Time or DateTime, questionnaire_id: Integer, saved_page: Integer, submitted: false or true, person_id: Integer, submitted_at: Time or DateTime, notes: String, type: String, position: Integer, caption: String, required: false or true, min: Integer, max: Integer, step: Integer, page_id: Integer, default_answer: String, layout: String, radio_layout: String, title: String, option: String, output_value: String, __all_joined: :questions or :pages or :responses or :answers or :question_options, __last_joined: :question_options, __selected: nil, __orm: false }>", wrap: false, typecheck: :later
RDL.type ResponsesCsvExporter, :each_row, "() {(%any) -> %any } -> %any", wrap: false, typecheck: :later
RDL.type GraphsController, :aggregate_questions, "(Array<Integer> or Integer) -> Hash<Integer, Hash<String, Integer>>", wrap: false, typecheck: :later
RDL.type GraphsController, :line, "() -> Array<String>", wrap: false, typecheck: :later
RDL.type GraphsController, :pie, "() -> Array<String>", wrap: false, typecheck: :later
RDL.type RootController, :get_new_questionnaires, "() -> ActiveRecord_Relation<Questionnaire>", wrap: false, typecheck: :later
RDL.type RootController, :dashboard, "() -> %any", wrap: false, typecheck: :later
RDL.type Answer, 'self.find_answer', "(Response, Question) -> Answer", wrap: false, typecheck: :later
RDL.type QuestionnairePermission, :email=, "(String) -> %any", wrap: false, typecheck: :later
## Bug found in the method below.
RDL.type Response, :verify_answers_for_page, "(Page) -> %any", wrap: false, typecheck: :later
RDL.type Response, :answer_for_question, "(Question) -> Answer", wrap: false, typecheck: :later
RDL.type QuestionnairesController, :index, "() -> Array<String> or String", wrap: false, typecheck: :later
RDL.type QuestionnairesController, :show, "() -> Array<String> or String", wrap: false, typecheck: :later
RDL.type AnswerController, :get_questionnaire, "() -> Questionnaire", wrap: false, typecheck: :later
RDL.type AnswerController, :save_answers, "() -> String", wrap: false, typecheck: :later
RDL.type AnswerController, :preview, "() -> Array<String>", wrap: false, typecheck: :later
RDL.type AnswerController, :questionnaire_closed, "() -> Questionnaire", wrap: false, typecheck: :later
RDL.type AnswerController, :prompt, "() -> Array<Response>", wrap: false, typecheck: :later
## Bug found in the method below
RDL.type AnswerController, :index, "() -> %any", wrap: false, typecheck: :later
RDL.type AnswerController, :resume, "() -> String", wrap: false, typecheck: :later
RDL.type ResponsesController, :get_email_notification, "() -> EmailNotification", wrap: false, typecheck: :later



### Annotations for variables and non-checked methods. These methods either come from the Journey app or from external libraries.
RDL.type ResponsesCsvExporter, :db, "() -> SequelDB", wrap: false
RDL.type RailsSequel, 'self.connect', "() -> SequelDB", wrap: false
RDL.type ResponsesCsvExporter, :questionnaire, "() -> Questionnaire", wrap: false
RDL.type ResponsesCsvExporter, :rotate, "() -> %bool", wrap: false
RDL.type Object, :blank?, "() -> %bool", wrap: false
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
RDL.type AnswerController, :params, "() -> { id: Integer, question: Hash<String, String>, current_page: Integer, commit: String, page: Integer }", wrap: false
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


## Call to `do_typecheck` will type check all the methods above with the :later label.
RDL.do_typecheck :later

