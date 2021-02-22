module ApplicationHelper

  # # change the default link renderer for will_paginate
  # def will_paginate(collection_or_options = nil, options = {})
  #   if collection_or_options.is_a? Hash
  #     options, collection_or_options = collection_or_options, nil
  #   end
  #   unless options[:renderer]
  #     options = options.merge :renderer => MyCustomLinkRenderer
  #   end
  #   super *[collection_or_options, options].compact
  # end

  # def paginate(collection, params= {})
  #   will_paginate collection, params.merge(:renderer => RemoteLinkPaginationHelper::LinkRenderer)
  # end

  def instruction_lines(recipe)
    i = 1
    html = []
    recipe.instructions.split("\r\n").each do |line|
      unless line == "" || line == " "
        html << "<div class='recipe-instructions'>
                   <div class='instruction-line'>
                     <div class='instruction-number'><h4>#{i}</h4></div>
                     <div class='instruction-text'><p>#{line}</p></div>
                   </div>
                </div>"
        i+=1
      end
    end
    return html.join.html_safe
  end

  def pdf_recipe_lines(recipe)
    i = 1
    html = []
    recipe.instructions.split("\r\n").each do |line|
      unless line == "" || line == " "
        html << "<div class='pdf-instructions'>
                   <div class='pdf-instruction-list'>
                     <div class='pdf-instruction-text'><p> #{line}</p></div>
                   </div>
                </div>"
        i+=1
      end
    end
    return html.join.html_safe
  end

  def meta_instruction_lines(instructions)
    i = 1
    html = []
    instructions.split("\r\n").each do |line|
      unless line == "" || line == " "
        html << "<div class='recipe-instructions'>
                   <div class='instruction-line'>
                     <div class='instruction-number'><h4>#{i}</h4></div>
                     <div class='instruction-text'><p>#{line}</p></div>
                   </div>
                </div>"
        i+=1
      end
    end
    return html.join.html_safe
  end

    def meta_ingredients_lines(ingredients)
    html = []
    ingredients.split("\r\n").each do |line|
      unless line == "" || line == " "
        html << "<div class='recipe-ingredients__list__item'>
                     <p>#{line}</p>
                </div>"
      end
    end
    return html.join.html_safe
  end

  def pdf_clean_item(item)
    html = []
    item = item.chomp(',')
    item = item.chomp('.')
    html << "<li class='pdf-list-item'>
                <p>#{item}</p>
              </li>"
    return html.join.html_safe
  end

  def show_shelves(foods)
    html = []

    shelves = Food.get_shelves(foods)
    types = Hash.new
    types["viandes et poissons"] = "redTag"
    types["céréales"] = "yellowTag"
    types["fruits et légumes"] = "greenTag"
    types["légumineuses"] = "purpleTag"
    types["oléagineux"] = "lightredTag"
    types["crèmerie"] = "orangeTag"
    types["épicerie"] = "blueTag"

    types.each do |type, tag|
      unless shelves["#{type}"].nil?
        shelves.has_key?("#{type}")
        html << "<div class=\"tagContainer\">"
        # html << "<h5><strong>#{type}</strong></h5>"
        shelves["#{type}"].each do |food|
          html << "<div class=\"tags #{tag}\">#{food.name}</div>"
        end
        html << "</div>"
      end

    end
    return html.join.html_safe
  end
end
