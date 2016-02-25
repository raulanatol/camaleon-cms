module CamaleonCms::CacheHelper
  require 'cache'

  def cache_hash(first_id, second_id, third_id)
    Base64.urlsafe_encode64("#{first_id}::#{second_id}::#{third_id}").chomp.tr('=\n', '')
  end

  def cached(first_id, second_id, third_id = '-')
    init_cache
    if @cache.nil?
      yield
    else
      cache_hash_key = cache_hash(first_id, second_id, third_id)
      if @cache.exist?(cache_hash_key)
        @cache.get(cache_hash_key)
      else
        response = yield
        @cache.set(cache_hash_key, response, 2.weeks)
        response
      end
    end
  end

  def clear_cache(first_id, second_id, third_id = '-')
    init_cache
    @cache.delete cache_hash(first_id, second_id, third_id) unless @cache.nil?
  end

  private

  def init_cache
    @cache ||= Cache.wrap(Rails.cache)
  end
end