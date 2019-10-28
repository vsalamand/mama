class ReportMailerPreview < ActionMailer::Preview
  def report_item
    item = Item.last
    # This is how you pass value to params[:user] inside mailer definition!
    ReportMailer.report_item(item)
  end

  def report_product
    product = Product.last
    # This is how you pass value to params[:user] inside mailer definition!
    ReportMailer.report_product(product)
  end
end
