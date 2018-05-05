require_relative 'db_types.rb'
require_relative 'ar_types.rb'

RDL.nowrap ActiveRecord::Associations::ClassMethods

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
    if a.name.to_s.pluralize == a.name.to_s ## plural association
      RDL.type model, a.name, "() -> ActiveRecord_Relation<#{a.class_name}>", wrap: false ## TODO: This actually returns an Associations CollectionProxy, which is a descendant of ActiveRecord_Relation (see below actual type). Not yet sure if this makes a difference in practice.
      #ActiveRecord_Associations_CollectionProxy<#{a.name.to_s.camelize.singularize}>'
    else
      ## association is singular, we just return an instance of associated class
      RDL.type model, a.name, "() -> #{a.class_name}", wrap: false
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
RDL.type ActiveRecord_Relation, :valid, "() -> ``if trec.params[0].name == 'Response' then trec else raise 'unexpected param type' end ``", wrap: false
RDL.type ActiveRecord_Relation, :no_answer_for, "(``if trec.params[0].name == 'Response' then RDL::Type::NominalType.new(Question) else raise 'unexpected param type' end``) -> self", wrap: false


### TYPE CHECKED METHODS
RDL.type ResponsesCsvExporter, :answers_table, "() -> Table<{ id: Integer, response_id: Integer, question_id: Integer, value: String, created_at: Time or DateTime, updated_at: Time or DateTime, questionnaire_id: Integer, saved_page: Integer, submitted: false or true, person_id: Integer, submitted_at: Time or DateTime, notes: String, type: String, position: Integer, caption: String, required: false or true, min: Integer, max: Integer, step: Integer, page_id: Integer, default_answer: String, layout: String, radio_layout: String, title: String, option: String, output_value: String, __all_joined: :questions or :pages or :responses or :answers or :question_options, __last_joined: :question_options, __selected: nil, __orm: false }>", wrap: false, typecheck: :later
RDL.type ResponsesCsvExporter, :each_row, "() {(%any) -> %any } -> %any", wrap: false, typecheck: :later
RDL.type GraphsController, :aggregate_questions, "(Array<Integer>) -> Float", wrap: false, typecheck: :later ## TODO: small error here concerning updating of param hash. See if you can figure this out.

RDL.do_typecheck :later
