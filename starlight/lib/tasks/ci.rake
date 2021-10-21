# frozen_string_literal: true

task ci: %w[standard spec] unless Rails.env.production?
