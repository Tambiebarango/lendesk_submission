# frozen_string_literal: true

class Api::FooController < ApplicationController
  def show
    render json: { foo: 'bar' }, status: :ok
  end
end
