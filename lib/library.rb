class Library
  attr_accessor :collection

  def initialize
    @collection = load_collection
  end
  
  def load_collection
    collection = YAML.load_file('./lib/data.yml')
    collection.length.nil? ? 'No books in the library' : collection
  end
  
  def view_collection
    @collection.each {|key, value| puts "#{key[:item][:title]} : #{key[:item][:author]}"}
  end

  def search(search_item)
    item_title = search_title(search_item)
    item_author = search_author(search_item)
    item_title.length > 0 ? item_title : item_author.length > 0 ? item_author : 'no such book'
  end

  def search_title(search_item)
    @collection.select { |obj| obj[:item][:title].include?search_item }
  end

  def search_author(search_item)
    @collection.select { |obj| obj[:item][:author].include?search_item }
  end

  def search_bookindex(book_title)
    @collection.to_a.index {|key,| key[:item][:title] == book_title}
  end

  def check_out(search_item, account_nr)
    book_title = search(search_item)[0][:item][:title]
    index = search_bookindex(book_title)
    book = @collection[index]
    book[:available] ?  set_check_out(book, account_nr) : not_availible(book)
  end 
  
  def not_availible(book)
    "Book not availible right now, back in library #{book[:return_date]}"
  end

  def set_check_out(book, account_nr)
    book[:available] = false
    book[:return_date] = "#{Date.today.next_month(1).strftime("%Y/%m/%d")}"
    book[:account_nr] = account_nr
    write_to_file
    book
  end

  def check_in(book_title)
    index = search_bookindex(book_title)
    book = @collection[index]
    book[:available] = true
    book[:return_date] = nil
    book[:account_nr] = nil
    write_to_file
    book 
  end 

  def user_booklist(account_nr)
    book_list = @collection.select { |obj|obj[:account_nr] == account_nr }
    book_list.length == 0 ? 'no books checked out' : book_list 
  end
  
  private

  def write_to_file
    File.open('./lib/data.yml', 'w') { |f| f.write @collection.to_yaml }
  end
end
