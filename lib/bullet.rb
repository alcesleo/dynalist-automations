require "./lib/markdown"

# Represents a single bullet point
class Bullet
  TAG_MARKERS = ["#", "@"]
  DATE_MARKER = /!\((.+?)\)/

  attr_reader :id, :content, :note, :checked, :file_id, :children_ids

  def initialize(id:, content:, note:, checked:, file_id:, children_ids: [])
    @id      = id
    @content = content
    @note    = note
    @checked = checked
    @file_id = file_id
    @children_ids = children_ids
  end

  alias_method :checked?, :checked

  def self.from_json(file_id, json)
    new(
      file_id:      file_id,
      id:           json.fetch("id"),
      content:      json.fetch("content"),
      note:         json.fetch("note"),
      checked:      json.fetch("checked"),
      children_ids: json.fetch("children") { [] }
    )
  end

  def inspect
    %(#<Bullet: "#{content}">)
  end

  def has_tag?(tag)
    TAG_MARKERS.any? { |marker| content.match?(marker + tag) || note.match?(marker + tag) }
  end

  def match(regexp)
    content.match(regexp) || note.match(regexp)
  end

  def date
    date_string = match(DATE_MARKER)

    Date.parse(date_string[1]) unless date_string.nil?
  end

  # Returns a hash where the key is which area to edit (content/note) and the value is the new text
  def update_date(new_date)
    new_date_tag = "!(#{new_date.to_date.to_s})"

    if content.match(DATE_MARKER)
      { content: content.sub(DATE_MARKER, new_date_tag) }
    elsif note.match(DATE_MARKER)
      { note: note.sub!(DATE_MARKER, new_date_tag) }
    else
      { note: note.empty? ? new_date_tag : "#{note} #{new_date_tag}" }
    end
  end

  def link
    "https://dynalist.io/d/#{file_id}#z=#{id}"
  end

  def to_html
    a = <<~HTML
      <a href="#{link}">
        <li>
          <div><b>#{Markdown.render(content)}</b></div>
          <div><i>#{Markdown.render(note)}</i></div>
        </li>
      </a>
    HTML
  end
end
