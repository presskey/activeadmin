require 'rails_helper' 

module ActiveAdmin
  describe Resource::Routes do
    before { load_defaults! }

    describe "route names" do
      context "when in the admin namespace" do
        let!(:config)  { ActiveAdmin.register Category }
        let(:category) { Category.new { |c| c.id = 123 } }

        it "should return the route prefix" do
          expect(config.route_prefix).to eq 'admin'
        end

        it "should return the route collection path" do
          expect(config.route_collection_path).to eq '/admin/categories'
        end

        context "when locale specified" do
          let(:locale) { :de }
          let(:params) { {locale: locale, other: 'xxx'} }

          it "should return the route collection path with locale parameter" do
            expect(config.route_collection_path(params)).to eq "/admin/categories?locale=#{locale}"
          end
        end

        it "should return the route instance path" do
          expect(config.route_instance_path(category)).to eq '/admin/categories/123'
        end
      end

      context "when in the root namespace" do
        let!(:config) { ActiveAdmin.register Category, namespace: false }
        it "should have a nil route_prefix" do
          expect(config.route_prefix).to be_nil
        end

        it "should generate a correct route" do
          reload_routes!
          expect(config.route_collection_path).to eq "/categories"
        end

        context "when locale specified" do
          let(:locale) { :de }
          let(:params) { {locale: locale, other: 'xxx'} }

          it "should generate a correct route with locale paramater" do
            reload_routes!
            expect(config.route_collection_path(params)).to eq "/categories?locale=#{locale}"
          end
        end
      end

      context "when registering a plural resource" do
        class ::News; def self.has_many(*); end end
        let!(:config) { ActiveAdmin.register News }
        before{ reload_routes! }

        it "should return the plural route with _index" do
          expect(config.route_collection_path).to eq "/admin/news"
        end

        context "when locale specified" do
          let(:locale) { :de }
          let(:params) { {locale: locale, other: 'xxx'} }

          it "should return the plural route with _index and locale parameter" do
            expect(config.route_collection_path(params)).to eq "/admin/news?locale=#{locale}"
          end
        end
      end

      context "when the resource belongs to another resource" do
        let! :config do
          ActiveAdmin.register Post do
            belongs_to :category
          end
        end

        let :post do
          Post.new do |p|
            p.id = 3
            p.category = Category.new{ |c| c.id = 1 }
          end
        end

        before{ reload_routes! }

        it "should nest the collection path" do
          expect(config.route_collection_path(category_id: 1)).to eq "/admin/categories/1/posts"
        end

        context "when locale specified" do
          let(:locale) { :de }
          let(:params) { {locale: locale, other: 'xxx'} }

          it "should nest the collection path and include locale" do
            expect(config.route_collection_path({category_id: 1}.merge(params))).to eq "/admin/categories/1/posts?locale=#{locale}"
          end
        end

        it "should nest the instance path" do
          expect(config.route_instance_path(post)).to eq "/admin/categories/1/posts/3"
        end
      end
    end
  end
end
