# frozen_string_literal: true

if defined?(Bullet)
  Bullet.enable = true
  Bullet.bullet_logger = true
  Bullet.raise = Rails.env.test?
end

