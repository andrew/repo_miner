require "spec_helper"

RSpec.describe RepoMiner do
  it "has a version number" do
    expect(RepoMiner::VERSION).not_to be nil
  end

  context "when mining the Libraries.io repository" do
    let(:analyser) { RepoMiner.analyse('.') }

    it "mines email addresses" do
      initial_commit = analyser.first
      expect(initial_commit.data[:email]).to eq({
        committer: 'andrewnez@gmail.com',
        author: 'andrewnez@gmail.com'
      })
    end

    it "mines dependencies" do
      initial_commit = analyser.first
      expect(initial_commit.data[:dependencies]).to eq({
        :added_manifests => [
          {:path=>"Gemfile",
            :platform=>"rubygems",
            :kind=>"manifest",
            :added_dependencies=>[],
            :modified_dependencies=>[],
            :removed_dependencies=>[]
          },
          {
            :path => "repo_miner.gemspec",
            :platform => "rubygems",
            :kind=>"manifest",
            :added_dependencies => [
              {:name=>"bundler", :requirement=>"~> 1.14", :type=>:development},
              {:name=>"rake", :requirement=>"~> 10.0", :type=>:development},
              {:name=>"rspec", :requirement=>"~> 3.0", :type=>:development}
            ],
            :modified_dependencies=>[],
            :removed_dependencies=>[]
          }
        ],
        :modified_manifests => [],
        :removed_manifests => [],
      })
    end

    it "finds modifications to existing dependencies" do
      fifth_commit = analyser[4]
      expect(fifth_commit.data[:dependencies]).to eq({
        :added_manifests => [],
        :modified_manifests => [
          {
            :path => "repo_miner.gemspec",
            :platform => "rubygems",
            :kind=>"manifest",
            :added_dependencies => [],
            :modified_dependencies=>[
              {
                :name=>"rake",
                :requirement=>"~> 12.0",
                :type=>:development,
                :previous_requirement=>"~> 10.0"
              }
            ],
            :removed_dependencies=>[]
          }
        ],
        :removed_manifests => [],
      })
    end
  end

  context "skipping already analysed commits" do
    it "starts analysing after the 'since' commit" do
      commits = RepoMiner.analyse('.', 'master', '00e7221')
      expect(commits.first.sha).to eq('a827c92a035e787760851d57a59c46b847518fe5')
    end
  end
end
