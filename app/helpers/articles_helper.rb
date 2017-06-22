require 'digest/md5'

module ArticlesHelper
	def gravatar_url(email_address)
		return if email_address.blank?

		hash = Digest::MD5.hexdigest(email_address)
		"https://www.gravatar.com/avatar/#{hash}"
	end
end
