module GitlabInt
	module ProjectPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)  
  
      base.class_eval do  
        alias_method_chain :delete_unsafe_attributes, :gitlab
        has_many :git_lab_repositories, dependent: :destroy
      end
    end
  
    module ClassMethods   
    end
  
    module InstanceMethods
    	def delete_unsafe_attributes_with_gitlab(attrs, user)
    		if attrs["gitlab_token"] && !attrs["gitlab_token"].empty?
    			create_gitlab_repository(attrs["gitlab_name"], attrs["gitlab_description"], attrs["visibility"], attrs["gitlab_token"])
    		end
    		delete_unsafe_attributes_without_gitlab(attrs, user)
    	end

      def create_gitlab_repository(name, description, visibility, token)
      	glr = GitLabRepository.new
      	glr.smart_attributes = { title: name, description: description, visibility: visibility, token: token }
      	glr.save
      	self.git_lab_repositories << glr
      end
    end
	end
end
