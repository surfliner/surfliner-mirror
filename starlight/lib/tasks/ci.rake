# frozen_string_literal: true

task ci: %w[rubocop spec] unless Rails.env.production?
