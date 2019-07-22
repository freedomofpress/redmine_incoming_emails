require File.expand_path("../../test_helper", __FILE__)

class IncomingEmailsMailHandlerTest < ActiveSupport::TestCase
  fixtures :projects, :enabled_modules, :issues, :users,
           :email_addresses, :user_preferences, :members,
           :member_roles, :roles, :tokens,
           :trackers, :projects_trackers,
           :issue_statuses, :enumerations, :versions

  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'

  def setup
    ActionMailer::Base.deliveries.clear
    User.current = nil
  end

  def teardown
    Setting.clear_cache
  end

  test "should preserve address of unkown user in issue body" do
    Role.anonymous.add_permission!(:add_issues)
    Role.anonymous.add_permission!(:add_issue_watchers)
    assert_no_difference 'User.count' do
      issue = submit_email(
                'ticket_by_unknown_user.eml',
                :issue => {:project => 'ecookbook'},
                :unknown_user => 'accept'
              )
      assert issue.is_a?(Issue)
      assert issue.author.anonymous?
      issue.reload
      assert issue.watched_by?(User.find_by_mail('dlopper@somenet.foo'))
      assert_equal 1, issue.watchers.size
      assert_include %{From: john.doe@somenet.foo}, issue.description
    end
  end

  test "should put incoming email into project configured for user" do
    issue = submit_email(
              'ticket.eml',
              issue: {tracker: 'Support request',
                         project: 'ecookbook'},
            )
    assert issue.is_a?(Issue)
    assert !issue.new_record?
    issue.reload
    assert_equal 'ecookbook', issue.project.identifier
    assert_equal 'Support request', issue.tracker.name

    # now, set a different project for the user
    with_settings(plugin_redmine_incoming_emails: {
      issue.author.mail => Project.find('onlinestore').id
    }) do
      issue = submit_email(
        'ticket.eml',
        issue: {tracker: 'Support request',
                project: 'ecookbook'},
      )
      assert issue.is_a?(Issue)
      assert !issue.new_record?
      issue.reload
      assert_equal 'onlinestore', issue.project.identifier
      assert_equal 'Support request', issue.tracker.name
    end
  end

  private

  def submit_email(filename, options={})
    raw = IO.read(File.join(FIXTURES_PATH, filename))
    yield raw if block_given?
    MailHandler.receive(raw, options)
  end
end
