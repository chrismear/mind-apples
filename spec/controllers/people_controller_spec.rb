require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PeopleController do
  def build_mock_person
    mock_person = mock_model(Person,
                             :ensure_correct_number_of_mindapples => nil,
                             :protected_login= => nil,
                             :page_code= => nil,
                             :save => true,
                             :update_attributes => true)
    mock_person
  end

  shared_examples_for "all actions finding a person" do
    it "should find a person by param value" do
      Person.expects(:find_by_param).with('param_value')
      do_request
    end
  end

  def do_request
    get 'show', :id => 'param_value'
  end

  describe "show" do
    it_should_behave_like "all actions finding a person"

    describe "when logged in as the user" do

      shared_examples_for "The user is the owner of a profile page" do
        it "doesn't redirect to the home page" do
          get 'show', :id => @person.login
          response.should_not redirect_to(root_path)
        end

        it "doesn't display a flash error message" do
          get 'show', :id => @person.login
          flash[:notice].should == nil
        end
        
        it "sets 'shared_mindapples? on the resource to true" do
          get 'show', :id => @person.login
          @person.reload
          @person.shared_mindapples?.should == true
        end
      end

      shared_examples_for "The user is not the owner of a profile page" do
        it "redirects to the home page" do
          get 'show', :id => @person.login
          response.should redirect_to(root_path)
        end

        it "displays a flash error message" do
          get 'show', :id => @person.login
          flash[:notice].should == "You don't have permission to see this page"
        end
      end


      describe "when visiting my own page and the page is not public" do
        before(:each) do
          @person = Factory.create(:person, :login => 'testThis', :public_profile => false)
          controller.stubs(:current_user).returns @person
          Person.stubs(:find_by_param).returns(@person)
        end

        it_should_behave_like "The user is the owner of a profile page"

      end

      describe "when visiting my own page and the page is public" do
        before(:each) do
          @person = Factory.create(:person, :login => 'testThis', :public_profile => true)
          controller.stubs(:current_user).returns @person
          Person.stubs(:find_by_param).returns(@person)
        end

        it_should_behave_like "The user is the owner of a profile page"
      end
    end

    describe "when not logged in as the user" do

      describe "when visiting a profile's page and the page is not public" do
        before(:each) do
          @person = Factory.create(:person, :login => 'testThis', :public_profile => false)
          @person.stubs(:to_param).returns('testThis')
          controller.stubs(:current_user).returns nil
          Person.stubs(:find_by_param).with('testThis').returns(@person)
        end

        it_should_behave_like "The user is not the owner of a profile page"
      end

      describe "when visiting a profile's page and the page is public" do
        before(:each) do
          @person = Factory.create(:person, :login => 'testThis', :public_profile => true)
          @person.stubs(:to_param).returns('testThis')
          controller.stubs(:current_user).returns nil
          Person.stubs(:find_by_param).with('testThis').returns(@person)
        end

        it_should_behave_like "The user is the owner of a profile page"
      end
    end
  end

  describe "edit" do
    describe "when logged in as the user" do
      before do
        @mock_person = build_mock_person
        controller.stubs(:current_user).returns @mock_person
        Person.stubs(:find_by_param).returns(@mock_person)
      end

      it_should_behave_like "all actions finding a person"
    end

    describe "when not logged in" do
      before do
        @mock_person = build_mock_person
        @mock_person.stubs(:to_param).returns('some_login')
        controller.stubs(:current_user).returns nil
        Person.stubs(:find_by_param).with('some_login').returns(@mock_person)
      end

      it "should set the return_to session value to the path for editing this user" do
        get 'edit', :id => 'some_login'
        session[:return_to].should == edit_person_path(@mock_person)
      end
    end
  end

  describe "update" do
    describe "user with blank password" do
      before(:each) do
        @mock_person = build_mock_person
        controller.stubs(:current_user).returns  @mock_person
        Person.stubs(:find_by_param).returns  @mock_person
        Person.stubs(:find_by_id).returns  @mock_person
        Person.stubs(:find_resource).returns( @mock_person)
      end

      it "fail if user is autogen with empty password and new login" do
        mock_person = @mock_person
        mock_person.stubs(:login_set_by_user?).returns false
        mock_person.stubs(:errors).returns(mock('error', :add))
        mock_person.stubs(:login).returns 'apple'
        mock_person.stubs(:[]=)

        mock_avatar = mock('avatar', :url => 'avatar_url')
        mock_person.stubs(:avatar).returns(mock_avatar)
        mock_person.stubs(:avatar=)
        mock_person.stubs(:attributes=)
        mock_person.stubs(:valid?)

        put(:update, "person" => {"login" => 'gandy', 'email' => 'gandy@post.com'})
      end

      it "doesn't fail if user is autogen with empty password and old login" do
        @mock_person.stubs(:login_set_by_user?).returns false
        mock_error = mock('error')
        mock_error.expects(:add).never.with('Please', " choose a valid password (minimum is 4 characters)")
        @mock_person.stubs(:errors).returns(mock_error)
        @mock_person.stubs(:login).returns 'gandy'

        put(:update, "person" => {"login" => 'gandy', 'email' => 'gandy@post.com', 'password' => ''})
      end

      it "doesn't fail if user is autogen with empty password" do
        @mock_person.stubs(:login_set_by_user?).returns true
        put(:update, "person" => {"login" => 'gandy', 'email' => 'gandy@post.com', 'password' => ''})
      end
    end

    it "doesn't fail if autogen user with filled password" do
      person = Factory(:person, :email => 'gandy@post.com', :login => 'autogen_abcdefgh', :page_code => 'abcdefgh')
      put(:update, "person" => {"login" => 'autogen_abcdefgh', 'email' => 'gandy@post.com', 'passsword' => 'supersecret',  'password_confirmation' => 'supersecret'})
    end

    describe "when logged in as the updated user" do
      before do
        @mock_person = build_mock_person
        controller.stubs(:current_user).returns @mock_person
        Person.stubs(:find_by_param).returns @mock_person
      end

      it "should set the login in a protected way on the updated resource" do
        PeopleController.any_instance.stubs(:password_invalid?).returns false
        mock_person = @mock_person

        mock_person.stubs(:avatar).returns('avatar')
        mock_person.stubs(:avatar=)
        mock_person.expects(:update_attributes)
        mock_person.expects(:protected_login=).with('gandy')

        Person.stubs(:find_by_param).returns mock_person
        put(:update, "person" => {"login" => 'gandy', 'email' => 'gandy@post.com'})
      end

      it "should redirect to the show page" do
        PeopleController.any_instance.stubs(:password_invalid?)
        PeopleController.any_instance.stubs(:update_logged_user)
        put(:update, "person" => {"login" => 'gandy', 'password' => 'asdasds'})
        response.should redirect_to(person_path(@mock_person))
      end

      it "should flash a thank you message" do
        PeopleController.any_instance.stubs(:password_invalid?)
        put(:update, "person" => {"login" => 'gandy'})
        flash[:notice].should =~ /thank you/i
      end

      it "find resource only for existed login" do
        nil_person = mock('nil_person')
        nil_person.stubs(:nil?).returns(true)
        Person.stubs(:find_by_param).returns(nil_person)
        mock_person = mock('person')
        ApplicationController.any_instance.stubs(:current_user).returns(mock_person)

        put(:update, "person" => {"login" => 'gandy', 'password' => 'topsecret', 'password_confirmation' => 'topsecret'})
      end
    end

    describe "doesn't update image with invalid validation" do
      before do
        @mock_person = build_mock_person
        controller.stubs(:current_user).returns @mock_person
        Person.stubs(:find_by_param).returns @mock_person
        PeopleController.any_instance.stubs(:password_invalid?).returns(mock)
        PeopleController.any_instance.stubs(:populate_resource).once
        @mock_person.stubs(:update_attributes).returns false
        @mock_person.stubs(:login).returns 'applesmind'
      end

      it "and load previous picture for avatar" do
        mock_person = @mock_person
        mock_avatar = mock('avatar', :url => 'avatar_url')
        mock_person.stubs(:avatar).returns(mock_avatar)
        Person.stubs(:find_by_id).returns mock_person
        mock_person.expects(:avatar=).with(mock_avatar)

        put(:update, "person" => {'login'=>'gandy'})
      end

      it "and set default picture for avatar" do
        mock_person = @mock_person
        mock_person.expects(:avatar).returns(mock('avatar', :url => Person.new.avatar.url))
        Person.stubs(:find_by_id).returns @mock_person
        @mock_person.expects(:avatar=)

        put(:update, "person" => {'login'=>'gandy'})
      end

    end

    describe "udpate logged user and reset the session" do
      before(:each) do
        @person = Factory(:person, :login => 'gandy', 'password' => 'topsecret', 'password_confirmation' => 'topsecret')
        controller.stubs(:current_user).returns @person
        Person.stubs(:find_by_param).returns @person
      end

      it "update user session on update" do
        PeopleController.any_instance.stubs(:password_invalid?).returns false
        controller.expects(:update_logged_user)
        put(:update, "person" => {"login" => 'gandy'})
      end

      it "set new user session if password was updated" do
        UserSession.expects(:create!).once.with(
                    :login => 'gandy',
                    :password => 'topsecret',
                    :password_confirmation => 'topsecret')
        put(:update, "person" => {"login" => 'gandy', 'password' => 'topsecret', 'password_confirmation' => 'topsecret'})
      end
    end

    describe "profile picture" do
      before(:each) do
        @person = Factory(:person, :login => 'gandy', 'password' => 'topsecret', 'password_confirmation' => 'topsecret')
        controller.stubs(:current_user).returns @person
        Person.stubs(:find_by_param).returns @person
        PeopleController.any_instance.stubs(:password_invalid?).returns false
      end

      it "delete if delete_checkbox is in params" do
         PeopleController.any_instance.expects(:delete_profile_picture).once
         put(:update, "person" => {"login" => 'gandy'}, 'delete_avatar' => 1)
      end

      it "don't delete if delete_checkbox is not int params" do
         PeopleController.any_instance.expects(:delete_profile_picture).never
         put(:update, "person" => {"login" => 'gandy'})
      end
    end

    describe "when logged in as a different user as the updated one" do
      before do
        @logged_in_person = build_mock_person
        controller.stubs(:current_user).returns @logged_in_person
        @mock_person = build_mock_person
        Person.stubs(:find_by_param).returns @mock_person
      end

      it "should not update any attributes of the updated user" do
        @mock_person.expects(:update_attributes).never
        put(:update, "person" => {"login" => 'gandy'})
      end

      it "should not update the login of the updated user" do
        @mock_person.expects(:protected_login=).never
        put(:update, "person" => {"login" => 'gandy'})
      end

      it "should set the notice flash" do
        put(:update, "person" => {"login" => 'gandy'})
        flash[:notice].should == 'You do not have permission to edit this page'
      end

      it "should redirect to the login page" do
        put(:update, "person" => {"login" => 'gandy'})
        response.should redirect_to(root_path)
      end
    end
  end

  describe "new" do
    before do
      @mock_person = build_mock_person
    end

    it "should create a new person with mindapples" do
      Person.expects(:new_with_mindapples)
      get :new
    end

    it "should have the new person as the resource" do
      Person.stubs(:new_with_mindapples).returns @mock_person
      get :new
      controller.resource.should == @mock_person
    end

    it "sets @network to nil if no network is passed" do
      get :new
      assigns[:network].should be_nil
    end

    it "sets @network to the network if a known one is passed" do
      network = Factory.create(:network)
      get :new, :network => network.url
      assigns[:network].should == network
    end

    it "renders a 404 if an unknown network is passed" do
      get :new, :network => "froob"
      response.should render_template('errors/error_404')
    end
  end

  describe "create" do
    it "should log the new person in" do
      @mock_person = build_mock_person
      Person.stubs(:new_with_mindapples).returns @mock_person
      UserSession.expects(:create!)
      post(:create, "person" => {:login => 'appleBrain', :password => 'supersecret', :email => 'my@email.com'})
    end

    it "should generate a page code" do
      PageCode.expects(:code).twice
      post(:create, "person" => {})
    end

    it "should assign the code as the page code" do
      @mock_person = build_mock_person
      Person.stubs(:new_with_mindapples).returns @mock_person
      UserSession.stubs(:create!)
      PageCode.stubs(:code).returns 'abzABz09'
      @mock_person.expects(:page_code=).with('abzABz09')
      post(:create, "person" => {})
    end

    it "should set the login in a protected way on the created resource" do
      @mock_person = build_mock_person
      Person.stubs(:new_with_mindapples).returns @mock_person
      Person.stubs(:find).returns @mock_person
      @mock_person.stubs(:valid_password?).returns true
      @mock_person.stubs(:changed?).returns false
      @mock_person.stubs(:last_request_at)
      @mock_person.stubs(:last_request_at=)
      @mock_person.stubs(:persistence_token)
      @mock_person.stubs(:avatar=)
      @mock_person.expects(:protected_login=).with('gandy')
      post(:create, "person" => {"login" => 'gandy'})
    end

    it "should generate a login if the login field is blank" do
      PageCode.stubs(:code).returns('genlogin')
      UserSession.expects(:create!).with has_entries(:login => Person::AUTOGEN_LOGIN_PREFIX + 'genlogin')
      post(:create, "person" => {"login" => ''})
    end

    context "with autogen login should redirect to" do
      it "edit page if params didn't contains pid" do
        PageCode.stubs(:code).returns('genlogin')
        UserSession.expects(:create!).with has_entries(:login => Person::AUTOGEN_LOGIN_PREFIX + 'genlogin')
        post(:create, "person" => {"login" => ''})
        response.should redirect_to(register_person_path(controller.resource))
      end

      it "show page if params contains pid" do
        PageCode.stubs(:code).returns('genlogin')
        UserSession.expects(:create!).with has_entries(:login => Person::AUTOGEN_LOGIN_PREFIX + 'genlogin')
        post(:create, "person" => {"login" => ''}, 'pid' => 123)
        response.should redirect_to(person_path(controller.resource))
      end
    end

    it "should assign the code as the autogen login if no login was passed" do
      PageCode.stubs(:code)
      PageCode.stubs(:code).returns 'abzABz09'
      post(:create, "person" => {})
      controller.resource.login.should == '%sabzABz09' % Person::AUTOGEN_LOGIN_PREFIX
    end

    it "should use a 20 character long code for the password and confirmation" do
      PageCode.stubs(:code).returns 'abcdef'
      PageCode.expects(:code).with(20).returns '20charlongpass'
      post(:create, "person" => {})
      controller.resource.password.should == '20charlongpass'
      controller.resource.password_confirmation.should == '20charlongpass'
    end

    it "should not set a default password if the password field was filled in" do
      post(:create, "person" => { :password => 'mypass' })
      controller.resource.password.should == 'mypass'
    end

    it "should not set a default password if the password confirmation field was filled in" do
      post(:create, "person" => { :password_confirmation => 'mypass' })
      controller.resource.password_confirmation.should == 'mypass'
    end

    it "should not set a default password if the login field was filled in" do
      post(:create, "person" => { :login => 'mypass' })
      controller.resource.password.should == nil
    end

    it "should set a default password if the password field was passed blank" do
      PageCode.stubs(:code).returns 'default_password'
      post(:create, "person" => { :password => '' })
      controller.resource.password.should == 'default_password'
    end

    it "should set a default password if the password confirmation field was passed blank" do
      PageCode.stubs(:code).returns 'default_password'
      post(:create, "person" => { :password_confirmation => '' })
      controller.resource.password_confirmation.should == 'default_password'
    end

    # it "don't validate email presence and uniquenes together" do
    #   person = Factory(:person)
    #   post(:create, "person" => { :email => '' })
    #   flash.now[:message].should == 'noo'
    # end

    it "should not allow a constructed form to create more than five mindapples" do
      post(:create, "person" =>
           {
             "mindapples_attributes" =>
             {
               "0" => {"suggestion" => "apple"},
               "1" => {"suggestion" => "banana"},
               "2" => {"suggestion" => "coconut"},
               "3" => {"suggestion" => "date"},
               "4" => {"suggestion" => "elderberry"},
               "5" => {"suggestion" => "fig"}
             }
           })
      controller.resource.mindapples.size.should == 5
    end

    describe "if user name is filled" do
      it "only with filled email" do
        person = mock('person', { :protected_login= => 'login', :page_code= => 'pagecode' })
        Person.stubs(:new_with_mindapples).returns(person)
        person.expects(:save).never
        post(:create, "person" => {'login' => 'bigapple', 'password' => 'supersecret'})
      end

      it "only with filled password" do
        person = mock('person', { :protected_login= => 'login', :page_code= => 'pagecode' })
        Person.stubs(:new_with_mindapples).returns(person)
        person.expects(:save).never
        post(:create, "person" => {'login' => 'bigapple', 'email' => 'my@email.com', 'password' => nil})
      end
    end

    it "delete genarated login from resource when validation fails" do
      person = mock('person', { :protected_login= => 'login', :page_code= => 'pagecode',:save => false })
      person.expects(:login=).once
      Person.stubs(:new_with_mindapples).returns(person)

      post(:create, "person" => {"login" => ''})
    end

    it "does not use the role field if passed as a param" do
      post(:create, "person" => {'login' => 'bigapple', "role" => "admin"})
      assigns[:person].role.should be_nil
    end

    describe "when saved" do
      before do
        @mock_person = build_mock_person
        @mock_person.stubs(:save).returns true
        Person.stubs(:new_with_mindapples).returns(@mock_person)
      end

      it "should redirect to show page" do
        UserSession.stubs(:create!)
        post(:create, "person" => {:login => 'appleBrain', :password => 'supersecret', :email => 'my@email.com'})
        response.should redirect_to(person_path(controller.resource))
      end

      it "renders flash message" do
        UserSession.stubs(:create!)
        post(:create, "person" => {:login => 'appleBrain', :password => 'supersecret', :email => 'my@email.com'})
        flash.now[:message].should == 'Thanks for sharing your mindapples!'
      end
    end

    describe "when there are errors" do
      before do
        @mock_person = build_mock_person
        @mock_person.stubs(:save).returns false
        @mock_person.stubs(:avatar=)
        @mock_person.stubs(:login=)
        Person.stubs(:new_with_mindapples).returns(@mock_person)
      end

      it "should render 'edit'" do
        post(:create, "person" => {})
        response.should render_template('edit')
      end

      it "render 404 error page" do
        get :show, :id => 'something'
        response.should render_template('errors/error_404')
      end
    end

    describe "setting the network from the network_url hidden field" do
      it "associates the person with the network if a network url is passed" do
        pending "can't seem to make this spec pass using mocha"
        # Factory.create(:network, :url => "bhm", :id => 28)
        # Person.expects(:new).returns mock('person') # .with(has_key(:network_id => 29))
        # # Person.should_receive(:new).with(hash_including(:network_id => 28))
        # post(:create, "person" => {}, "network_url" => "bhm")
      end

      it "needs more specs"
    end
  end

  describe "convert_policy_checked_value" do
    context "create" do
      it "save checked checkbox as true" do
        post(:create, "person" => {'policy_checked' => "1"})
        params['person']['policy_checked'].should == true
      end

      it "dont save unchecked checkbox as true" do
        post(:create, "person" => {'policy_checked' => "0"})
        params['person']['policy_checked'].should_not == true
      end

      it "dont save nil checkbox param as true" do
        post(:create, "person" => {})
        params['person']['policy_checked'].should be_nil
      end
    end

    context "update" do
      before do
        @person = Factory(:person, :login => 'gandy', 'password' => 'topsecret', 'password_confirmation' => 'topsecret')
        controller.stubs(:current_user).returns @person
        Person.stubs(:find_by_param).returns @person
      end

      it "save checked checkbox as true" do
        post(:update, "person" => {"login" => 'gandy', 'policy_checked' => "1"})
        params['person']['policy_checked'].should == true
      end

      it "dont save unchecked checkbox as true" do
        post(:update, "person" => {'policy_checked' => "0"})
        params['person']['policy_checked'].should_not == true
      end

      it "dont save nil checkbox param as true" do
        post(:update, "person" => {})
        params['person']['policy_checked'].should be_nil
      end
      
      it "should set the flash message correctly if the update comes from the register form" do
        post(:update, "person" => {"login" => 'gandy', 'policy_checked' => "1"}, "register_form" => "true")
        flash[:notice].should == "Thanks for registering your Mindapples page"
      end
    end
  end

  describe "like mindapples actions" do

    before(:each) do
      @person = Factory.create(:person, :email => "abcdef@ghijk.com")
      @owned_mindapple = Factory.create(:mindapple)
      @others_mindapple = Factory.create(:mindapple)

      @person.mindapples << @owned_mindapple
    end

    describe "like" do
      describe "when logged in" do

        before(:each) do
          @person = Factory.create(:person, :login => 'testThis', :public_profile => false)
          controller.stubs(:current_user).returns @person
          Person.stubs(:find_by_param).returns(@person)
        end

        it "should be successful" do
          mindapple = Factory.create(:mindapple)
          put :likes, :id => mindapple

          response.should be_success
        end

        it "adds a mindapple as liked by a user only if the user is not the owner" do
          mindapple = Factory.create(:mindapple)
          put :likes, :id => mindapple

          @person.liked_mindapples.size.should == 1
        end

        it "doesn't add a mindapple more than once" do
          mindapple = Factory.create(:mindapple)
          @person.liked_mindapples << mindapple

          put :likes, :id => mindapple

          @person.liked_mindapples.size.should == 1
        end

        it "redirects to the homepage if trying to add a mindapple more than once" do
          mindapple = Factory.create(:mindapple)
          @person.liked_mindapples << mindapple

          put :likes, :id => mindapple
          response.should redirect_to(root_path)
        end

        it "shows an error message if trying to add a mindapple more than once" do
          mindapple = Factory.create(:mindapple)
          @person.liked_mindapples << mindapple

          put :likes, :id => mindapple

          flash[:notice].should == "You can't like a mindapple more than once"
        end

        it "doesn't add a mindapple to a user's liked ones if the user is the owner of the mindapple" do
          mindapple = Factory.create(:mindapple)
          @person.mindapples << mindapple
          put :likes, :id => mindapple

          @person.liked_mindapples.should_not include(mindapple)
        end

        it "redirects to the homepage if the user tries to like one of its mindapples" do
          mindapple = Factory.create(:mindapple)
          @person.mindapples << mindapple
          put :likes, :id => mindapple

          response.should redirect_to(root_path)
        end

        it "shows an error message if the user tries to like one of its mindapples" do
          mindapple = Factory.create(:mindapple)
          @person.mindapples << mindapple
          put :likes, :id => mindapple

          flash[:notice].should == "Sorry, you can't like one of your own mindapples"
        end

        it "doesn't add a mindapple if it doesn't exist" do
          put :likes, :id => -1

          @person.liked_mindapples.should be_empty
        end

        it "redirects to the homepage if trying to add a mindapple that doesn't exist" do
          put :likes, :id => -1

          response.should redirect_to(root_path)
        end

        it "shows an error message if trying to add a mindapple that doesn't exist" do
          put :likes, :id => -1

          flash[:notice].should == "Unknown mindapple, couldn't finish the operation"
        end

      end

      describe "when not logged in" do
        before(:each) do
          @person = Factory.create(:person, :login => 'testThis', :public_profile => false)
          @person.stubs(:to_param).returns('testThis')
          controller.stubs(:current_user).returns nil
          Person.stubs(:find_by_param).with('testThis').returns(@person)
        end

        it "redirects to the homepage" do
          mindapple = Factory.create(:mindapple)
          put :likes, :mindapple => mindapple

          response.should redirect_to(root_path)
        end

        it "shows an error message" do
          mindapple = Factory.create(:mindapple)
          put :likes, :mindapple => mindapple

          flash[:notice].should == "You must be logged in to like a mindapple"
        end

        it "doesn't add a mindapple as liked by a user that doesn't own the mindapple" do
          mindapple = Factory.create(:mindapple)
          put :likes, :mindapple => mindapple

          @person.liked_mindapples.should be_empty
        end

        it "doesn't add a mindapple to a user's liked ones when the user owns the mindapple" do
          mindapple = Factory.create(:mindapple)
          @person.mindapples << mindapple
          put :likes, :mindapple => mindapple

          @person.liked_mindapples.should_not include(mindapple)
        end

        it "doesn't add a mindapple if it doesn't exist" do
          put :likes, :mindapple => -1

          @person.liked_mindapples.should be_empty
        end

      end

    end

    describe "unlike" do
      describe "when logged in" do

        before(:each) do
          @person = Factory.create(:person, :login => 'testThis', :public_profile => false)
          controller.stubs(:current_user).returns @person
          Person.stubs(:find_by_param).returns(@person)
        end

        # it "should be successful" do
        #   mindapple = Factory.create(:mindapple)
        #   put :unlikes, :id => mindapple
        #
        #   response.should be_success
        # end

        it "removes a mindapple from a user's liked_mindapples only if the user previously liked it" do
          mindapple = Factory.create(:mindapple)
          @person.liked_mindapples << mindapple

          put :unlikes, :id => mindapple

          @person.liked_mindapples.should_not include(mindapple)
        end

        it "doesn't do anything  if the user didn't previously like it" do
          mindapple = Factory.create(:mindapple)

          put :unlikes, :id => mindapple

          @person.liked_mindapples.should be_empty
        end

        it "redirects to the homepage if the user didn't previously like it" do
          mindapple = Factory.create(:mindapple)

          put :unlikes, :id => mindapple

          response.should redirect_to(root_path)
        end

        it "shows an error message if the user didn't previously like it" do
          mindapple = Factory.create(:mindapple)

          put :unlikes, :id => mindapple

          flash[:notice].should == "You need to like a mindapple first before you can unlike it!"
        end

        it "doesn't remove a mindapple from another user's liked_mindapples" do
          mindapple = Factory.create(:mindapple)
          another_person = Factory.create(:person, :email => "emailTestEmail@email.com")

          another_person.liked_mindapples << mindapple

          put :unlikes, :id => mindapple

          another_person.liked_mindapples.size.should == 1
        end

        it "redirects to the homepage if trying to unlike another's liked_mindapples" do
          mindapple = Factory.create(:mindapple)
          another_person = Factory.create(:person, :email => "newEmailTestEmail@email.com")

          another_person.liked_mindapples << mindapple

          put :unlikes, :id => mindapple

          response.should redirect_to(root_path)
        end
      end

      describe "when not logged in" do
        before(:each) do
          @person = Factory.create(:person, :login => 'testThis', :public_profile => false)
          @person.stubs(:to_param).returns('testThis')
          controller.stubs(:current_user).returns nil
          Person.stubs(:find_by_param).with('testThis').returns(@person)
        end

        it "redirects to the homepage" do
          mindapple = Factory.create(:mindapple)
          put :unlikes, :id => mindapple

          response.should redirect_to(root_path)
        end

        it "doesn't remove a mindapple from a user's liked_mindapples if the user previously liked it" do
          mindapple = Factory.create(:mindapple)
          @person.liked_mindapples << mindapple

          put :unlikes, :id => mindapple

          @person.liked_mindapples.should include(mindapple)
        end

        it "doesn't do anything  if the user didn't previously like it" do
          mindapple = Factory.create(:mindapple)

          put :unlikes, :id => mindapple

          @person.liked_mindapples.should be_empty
        end

        it "doesn't remove a mindapple from another user's liked_mindapples" do
          mindapple = Factory.create(:mindapple)
          another_person = Factory.create(:person, :email => "stset@email.com")

          another_person.liked_mindapples << mindapple

          put :unlikes, :id => mindapple

          another_person.liked_mindapples.size.should == 1
        end

        it "shows a error message" do
          mindapple = Factory.create(:mindapple)
          put :unlikes, :id => mindapple

          flash[:notice].should == "You must be logged in to unlike a mindapple"
        end
      end

    end
  end

  describe "favourites" do
    it "should return the favourites in @favourites" do
      person = Factory.create(:person, :email => "e@mail.com", :login => 'login_test')
      mindapple_1 = Factory.create(:mindapple)
      mindapple_2 = Factory.create(:mindapple)
      person.liked_mindapples << mindapple_1
      person.liked_mindapples << mindapple_2

      get :favourites, :id => person.login

      assigns[:favourites].size.should == person.liked_mindapples.size
    end
  end
  
  describe "register" do
    it "should redirect the user to root if the the user is not logged in" do
      person = Factory.create(:person, :email => "e@mail.com", :login => 'login_test')
      get :register, :id => person.login
      response.should redirect_to(root_path)
    end
  end
end
