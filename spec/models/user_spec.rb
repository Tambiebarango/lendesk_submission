# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    context "username not unique" do
      it "should not be valid" do
        user = User.create(username: "test", password: "StrongPassword123!")

        new_user = User.new(username: "test", password: "StrongPassword123!")

        expect(new_user.valid?).to be_falsey
      end
    end

    context "password" do
      context "when password doesn't have uppercase" do
        it "should not be valid" do
          new_user = User.new(username: "test", password: "strongPassword123!")

          expect(new_user.valid?).to be_falsey
        end
      end

      context "when password is shorter than 8 chars" do
        it "should not be valid" do
          new_user = User.new(username: "test", password: "Stpas1!")

          expect(new_user.valid?).to be_falsey
        end
      end
      
      context "when password is longer than 70 chars" do
        it "should not be valid" do
          password = "Stpas1!"*12
          new_user = User.new(username: "test", password: password)

          expect(new_user.valid?).to be_falsey
        end
      end

      context "when password doesn't contain number" do
        it "should not be valid" do
          new_user = User.new(username: "test", password: "Stpasasd!")

          expect(new_user.valid?).to be_falsey
        end
      end
      
      context "when password doesn't special char" do
        it "should not be valid" do
          new_user = User.new(username: "test", password: "Stpasasdf1")

          expect(new_user.valid?).to be_falsey
        end
      end
    end
  end
end
