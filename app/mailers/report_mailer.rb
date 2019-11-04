class ReportMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.report_mailer.report_item.subject
  #
  def report_item(item)
    @item = item
    mail(to: "mama@clubmama.co", subject: "[clubmama][report][item]")
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.report_mailer.report_product.subject
  #
  def report_product(product)
    @product = product
    mail(to: "mama@clubmama.co", subject: "[clubmama][report][product]")
  end
end
