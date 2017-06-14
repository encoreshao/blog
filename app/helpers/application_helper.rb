module ApplicationHelper
	def banner_iamge_url
		"/assets/photos/banner-00#{1+rand(6)}.jpg"
	end

	def friendly_links
		{
			'Ekohe' => 'https://ekohe.com'
		}
	end
end
