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

  def pdf_clean_item(item)
    html = []
    item = item.chomp(',')
    item = item.chomp('.')
    html << "<li class='pdf-list-item'>
                <p>#{item}</p>
              </li>"
    return html.join.html_safe
  end
end
