require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UserSessionsController do
  def build_mock_session
    mock_model(UserSession,
               :priority_record= => nil,
               :persisting? => nil
               )
  end

  describe "create" do
    before do
      controller.stubs(:require_no_user)
    end

    it "should log the current logged in user out" do
      @person = Factory.create(:person)
      @mock_session = build_mock_session
      @mock_session.stubs(:person).returns @person
      UserSession.stubs(:find).returns(@mock_session)
      @mock_session.expects(:destroy)
      post(:create, "session" => {})
    end

    describe "when saved" do
      before do
        @person = Factory.create(:person)
        @mock_session = build_mock_session
        @mock_session.stubs(:save).returns true
        @mock_session.stubs(:person).returns @person
        @mock_session.stubs(:destroy)
        UserSession.stubs(:new).returns(@mock_session)
        UserSession.stubs(:find).returns(@mock_session)
      end

      it "should set the flash notice with login successful" do
        post(:create, "session" => {})
        flash[:notice].should == "Login successful!"
      end

      it "should redirect back to account path if redirect back is not set and no network was passed" do
        post(:create, "session" => {})
        response.should redirect_to(person_path(@person))
      end

      it "should redirect back to network path if redirect back is not set and no network was passed" do
        network = Factory.create(:network, :id => 999)
        post(:create, "session" => {}, "network_id" => "999")
        response.should redirect_to(network_path(network))
      end
    end
  end

  describe "when not saved" do
    before do
      @mock_session = build_mock_session
      @mock_session.stubs(:save).returns false
      UserSession.stubs(:new).returns(@mock_session)
    end

    it "should render new" do
      post(:create, "session" => {}, "network_id" => 777)
      response.should render_template("new")
    end

    it "assigns to @network, the network that was passed as a param" do
      Network.stubs(:find_by_id).with("777").returns(:mock_network)
      post(:create, "session" => {}, "network_id" => 777)
      assigns[:network].should == :mock_network
    end
  end

  describe "destroy" do
    before do
      @person = Factory.create(:person)
      @mock_session = build_mock_session
      @mock_session.stubs(:destroy)
      @mock_session.stubs(:person).returns @person
      UserSession.stubs(:find).returns(@mock_session)
      controller.stubs(:require_user)
    end

    it "should destroy the current user session" do
      @mock_session.expects(:destroy)
      delete :destroy, "session" => {}
    end

    it "should set the flash notice with logout successful" do
      delete :destroy, "session" => {}
      flash[:notice].should == "Logout successful!"
    end

    it "should redirect back to account path redirect back is not set" do
      delete :destroy, "session" => {}
      response.should redirect_to(person_path(@person))
    end

  end
end
