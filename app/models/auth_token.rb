class AuthToken < ActiveRecord::Base
	def set(token)
		self.token = token
		self.save
	end
end
