application = 'myapp'

# ワーカープロセス数: CUPコア数の2倍程度に設定
worker_processes 4

#15秒応答がなければワーカーをkill
timeout 600

app_path = '/var/www/vhost/bizstore/current'
working_directory = app_path

# PID, ソケット
listen  File.expand_path('tmp/sockets/unicorn.sock', app_path)
pid File.expand_path('tmp/pids/unicorn.pid', app_path)
# ログ
stderr_path File.expand_path('log/unicorn.stderr.log', app_path)
stdout_path File.expand_path('log/unicorn.stdout.log', app_path)

# ダウンタイム無しでデプロイ可
preload_app true

GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!

  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end

  sleep 1
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
