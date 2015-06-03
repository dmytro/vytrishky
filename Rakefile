REMOTE="origin"
SOURCE_BRANCH="master"
PUBLISH_BRANCH="gh-pages"
DATE=Time.now.strftime("%Y/%m/%d %H:%M")

desc "compile and publish the site to Github"
task :publish do
  sh "git checkout #{SOURCE_BRANCH}"
  comment = %x{ git log -n 1 --no-merges --format=%s%b }.chomp.strip
  sh "bundle exec middleman build"
  sh "cd build && git add -A && git commit -m \"At #{DATE} #{comment}\" && git push #{REMOTE} #{PUBLISH_BRANCH}"
  sh "git push origin #{SOURCE_BRANCH}"
end

