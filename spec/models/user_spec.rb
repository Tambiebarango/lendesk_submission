# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    allow(BCrypt::Password).to receive(:new).and_return("password_hash")
  end
  
  describe "#self.find" do
    context "when user does not exist" do
      it "should return nil" do
        result = User.find("doesnotexist")

        expect(result).to be_nil
      end
    end

    context "when user exists" do
      it "should return user object" do
        $redis.hset("User-testuser", "username", "testuser", "password", "password!21")

        result = User.find("testuser")

        expect(result.username).to eq "testuser"
        expect(result.password).to eq "password_hash"
      end
    end
  end

  describe "#self.create" do
    context "validations" do
      context "username not unique" do
        it "should raise error" do
          $redis.hset("User-testuser", "username", "testuser", "password", "password!21")
  
          expect {
            User.create(
              username: "testuser",
              password: "StrongPassword123!"
            )
          }.to raise_error(RuntimeError, "Username must be unique")
        end
      end

      context "username not present" do
        it "should raise error" do
          expect {
            User.create(
              username: nil,
              password: "StrongPassword123!"
            )
          }.to raise_error(RuntimeError, "Username can't be blank")
        end
      end

      context "password" do
        it "should raise error when no uppercase" do
          expect {
            User.create(
              username: "testuser",
              password: "strongpassword123!"
            )
          }.to raise_error(RuntimeError, "Password must be complex")
        end

        it "should raise error when password is shorter than 8 chars" do
          expect {
            User.create(
              username: "testuser",
              password: "sE23!"
            )
          }.to raise_error(RuntimeError, "Password must be complex")
        end
        
        it "should raise error when password is longer than 70 chars" do
          expect {
            User.create(
              username: "testuser",
              password: "sE23!"*80
            )
          }.to raise_error(RuntimeError, "Password must be complex")
        end
        
        it "should raise error when password doesn't have number" do
          expect {
            User.create(
              username: "testuser",
              password: "StrongPassword!"
            )
          }.to raise_error(RuntimeError, "Password must be complex")
        end
        
        it "should raise error when password doesn't have special char" do
          expect {
            User.create(
              username: "testuser",
              password: "StrongPassword"
            )
          }.to raise_error(RuntimeError, "Password must be complex")
        end
      end
    end
  end

  describe "#correct_password?" do
    context "when pword is wrong" do
      it "should return false" do
        user = User.new(username: "testuser", password: "password")
        
        expect(user.correct_password?("wrong")).to be false
      end
    end
    
    context "when pword is correct" do
      it "should return true" do
        user = User.new(username: "testuser", password: "password")
        
        expect(user.correct_password?("password")).to be true
      end
    end
  end

  describe "to_h" do
    it "should return hash with username" do
      user = User.new(username: "testuser", password: "password")

      expect(user.to_h).to eq({ username: "testuser" })
    end
  end

  describe "#db_id" do
    it "should append User to user's username" do
      user = User.new(username: "testuser", password: "password")

      expect(user.db_id).to eq("User-testuser")
    end
  end
end
