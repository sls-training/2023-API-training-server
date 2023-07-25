# frozen_string_literal: true

ApiPagination.configure do |config|
  config.page_header = 'Page'
  config.per_page_header = 'Per'

  config.per_page_param = :per
end
