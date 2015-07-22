require 'foreign'

module V1
	class Bookshelves < Grape::API

		# このクラス内で共通化出来る処理は helper に書く
    helpers do
			include V1::Helpers    # emit_empty などを使えるようにする（必須）

			def find_by_id (userid, bookid)
					bookshelf = Bookshelf.find_by user_id: userid, book_id: bookid
					emit_error "指定した book_id が見つかりません", 400, 1 unless bookshelf
					bookshelf
			end
    end

		resource :bookshelves do
			get :test do
				Bookshelf.all
			end

			params do
				requires :user_id, type: Integer, desc: "UserID"
			end
			route_param :user_id do

				desc "Get a bookshelf."
				get '/' , jbuilder: 'bookshelves/bookshelves' do
					@bookshelves = Bookshelf.where(user_id: params[:user_id])
				end

				desc "post a bookshelf"
				params do
					requires :book_id, type: Integer, desc: "adding book ID"
				end
				post '/' , jbuilder: 'empty' do
					if Bookshelf.find_by user_id: params[:user_id], book_id: params[:book_id]
						emit_empty "すでに登録されているタイトル", 400, 1
					else
						Bookshelf.create user_id: params[:user_id], book_id: params[:book_id], borrower_id: 0
					end
				end

				resource :search do
					params do
						optional :book_id, type: Integer, desc: "bookID"
						optional :title, type: String, desc: "title of the book"
					end
					get '/' , jbuilder: 'books/books' do
						if params[:book_id]
							book_by_id = Bookshelf.find_by( user_id: params[:user_id], book_id: params[:book_id])
							@books = Book.where(id: book_by_id)
						else
							if params[:title]  #sample:   http://localhost:3000/bookshare/api/v1/bookshelves/1/search?title=Book1
								book_by_title = Book.where("title like '%" + params[:title] + "%'").map(&:id)
								book_by_title = Bookshelf.where(book_id: book_by_title).map(&:book_id)
								@books = Book.where(id: book_by_title)
							end
						end
					end
				end

				desc "Delete a bookshelf."
				delete '/', jbuilder: 'empty' do
					@bookshelf = Bookshelf.where(user_id: params[:user_id])
					return unless @bookshelf

					@bookshelf.each do |book|
						book.destroy
					end
				end

				params do
					requires :book_id, type: Integer, desc: "bookID"
				end
				route_param :book_id do

					get '/', jbuilder: 'books/book' do
						book_by_id = Bookshelf.where(user_id: params[:user_id]).map(&:book_id)

						if book_by_id.include?(params[:book_id])
							@book = Book.find_by id: params[:book_id]
						else
							emit_error! "存在しない本", 400, 1
						end
					end

					desc "Change property of a book on bookshelf."
					params do
						optional :borrower_id, type: Integer, desc: "borrowerID"
						optional :rate, type: Integer, desc: "interest rate of book"
						optional :comment, type: String, desc: "review of book"
					end
					put '/', jbuilder: 'empty' do
						@bookshelf = Bookshelf.find_by user_id: params[:user_id], book_id: params[:book_id]
						return unless @bookshelf
						if params[:borrower_id]
							@bookshelf.update borrower_id: params[:borrower_id]
						end
						if params[:rate]
							@bookshelf.update rate: params[:rate]
						end
						if params[:comment]
							@bookshelf.update comment: params[:comment]
						end
					end

					desc "Delete a book on bookshelf."
					delete '/', jbuilder: 'empty' do
						@bookshelf = Bookshelf.find_by user_id: params[:user_id], book_id: params[:book_id]
						return unless @bookshelf
						@bookshelf.destroy
					end
				end
			end
		end
	end
end
