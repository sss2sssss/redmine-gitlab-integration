module GitlabInt
	module MemberPatch
		include GitlabMethods
		def self.included(base)
			base.send(:include, InstanceMethods)
			base.class_eval do
				# Patch only if module was enabled
				after_save :add_member_in_gitlab, if: :gitlab_module_enabled_and_token_exists?
				before_destroy :remove_member_in_gitlab, if: :gitlab_module_enabled_and_token_exists?
				after_update :edit_member_in_gitlab, if: :gitlab_module_enabled_and_token_exists?
			end
		end

		module InstanceMethods
			def gitlab_module_enabled_and_token_exists?
				(self.project.module_enabled?("GitLab") && Setting.plugin_gitlab_int['gitlab_members_sync'] == "true" &&
										  User.current.gitlab_token && !User.current.gitlab_token.empty?)
			end

			def add_member_in_gitlab
				repo_ids = self.project.git_lab_repositories.map(&:gitlab_id).compact
				role = self.member_roles.first.role_id
				gitlab_add_member(login: self.user.login, repositories: repo_ids, token: User.current.gitlab_token, role: role)
			end

			def remove_member_in_gitlab
				repo_ids = self.project.git_lab_repositories.map(&:gitlab_id).compact
				gitlab_remove_member(login: self.user.login, repositories: repo_ids, token: User.current.gitlab_token)
			end

			def edit_member_in_gitlab
				repo_ids = self.project.git_lab_repositories.map(&:gitlab_id).compact
				role = self.member_roles.last.role_id
				gitlab_edit_member(login: self.user.login, repositories: repo_ids, token: User.current.gitlab_token, role: role)
			end
		end
	end
end