module SimpleFields
  def self.string(name:, label:, **options)
    default_options("string")
      .merge(options)
      .merge(name: name, label: label)
  end

  def self.integer(name:, label:, **options)
    default_options("integer")
      .merge(options)
      .merge(name: name, label: label, control_type: "integer")
  end

  def self.text_area(name:, label:, **options)
    default_options("string")
      .merge(options)
      .merge(name: name, label: label, control_type: "text_area")
  end  

  def self.object(name:, label:, properties:, **options)
    {
      name: name,
      label: label,
      type: "object",
      properties: properties,
      sticky: true,
      optional: false
    }.merge(options)
  end

  def self.default_options(type)
    { type: type, control_type: "text", sticky: true, optional: false }
  end
end
