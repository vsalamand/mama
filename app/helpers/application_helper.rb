module ApplicationHelper
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

  def show_shelves(recipe)
    html = []

    shelves = recipe.get_shelves
    types = Hash.new
    types["Fruits et légumes"] = "greenTag"
    types["Céréales"] = "purpleTag"
    types["Viandes et poissons"] = "redTag"
    types["Crèmerie"] = "yellowTag"
    types["Epicerie"] = "blueTag"

    types.each do |type, tag|
      unless shelves["#{type}"].nil?
        shelves.has_key?("#{type}")
        html << "<h5><strong>#{type}</strong></h5>"
        shelves["#{type}"].each do |food|
          html << "<div class=\"tags #{tag}\">#{food.name}</div>"
        end
      end

    end
    return html.join.html_safe
  end
end
