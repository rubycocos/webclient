
# ============================================================
# Disk Cache
# ============================================================

class DiskCache
  def initialize(directory, ttl)
    @directory = directory
    @ttl = ttl

    FileUtils.mkdir_p(@directory)
  end

  def key(url)
    Digest::SHA256.hexdigest(url)
  end

  def paths(url)
    digest = key(url)

    {
      body:     File.join(@directory, "#{digest}.body"),
      metadata: File.join(@directory, "#{digest}.json")
    }
  end

  def exists?(url)
    paths = paths(url)
    File.exist?(paths[:body]) && File.exist?(paths[:metadata])
  end

  def get(url)
    return nil unless exists?(url)

    paths = paths(url)

    begin
      metadata = JSON.parse(File.read(paths[:metadata]))

      fetched_at = Time.parse(metadata.fetch("fetched_at"))

      if @ttl && (Time.now - fetched_at > @ttl)
        return nil
      end

      body = File.binread(paths[:body])

      {
        url:         metadata["url"],
        status:      metadata["status"],
        headers:     metadata["headers"] || {},
        content_type: metadata["content_type"],
        fetched_at:  fetched_at,
        body:        body
      }
    rescue StandardError => e
      warn "[CACHE] Failed reading #{url}: #{e.message}"
      nil
    end
  end

  def put(url, response)
    paths = paths(url)

    metadata = {
      "url"          => url,
      "status"       => response.code.to_i,
      "headers"      => response.each_header.to_h,
      "content_type" => response["content-type"],
      "fetched_at"   => Time.now.utc.iso8601
    }

    # Write temporary files first, then rename them.
    # This prevents partially-written cache entries.
    body_tmp = "#{paths[:body]}.tmp"
    meta_tmp = "#{paths[:metadata]}.tmp"

    File.binwrite(body_tmp, response.body)
    File.write(meta_tmp, JSON.pretty_generate(metadata))

    File.rename(body_tmp, paths[:body])
    File.rename(meta_tmp, paths[:metadata])

    true
  rescue StandardError => e
    warn "[CACHE] Failed writing #{url}: #{e.message}"
    false
  ensure
    File.delete(body_tmp) if body_tmp && File.exist?(body_tmp)
    File.delete(meta_tmp) if meta_tmp && File.exist?(meta_tmp)
  end
end
