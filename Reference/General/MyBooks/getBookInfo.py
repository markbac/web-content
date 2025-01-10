import pandas as pd
import requests

def get_book_info(isbn):
    """Fetch book information from Google Books API."""
    url = f"https://www.googleapis.com/books/v1/volumes?q=isbn:{isbn}"
    response = requests.get(url)
    if response.ok:
        data = response.json()
        if data['totalItems'] > 0:
            book = data['items'][0]['volumeInfo']
            title = book.get('title', 'N/A')
            subtitle = book.get('subtitle', 'N/A')
            authors = ', '.join(book.get('authors', ['N/A']))
            edition = book.get('edition', 'N/A')
            description = book.get('description', 'N/A')
            image_link = book.get('imageLinks', {}).get('thumbnail', 'N/A')
            return title, subtitle, authors, edition, description, image_link
        else:
            return 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A'
    else:
        return 'N/A', 'N/A', 'N/A', 'N/A', 'N/A', 'N/A'

def save_to_markdown(df, filename):
    """Save the DataFrame to a Markdown file."""
    with open(filename, 'w') as file:
        for index, row in df.iterrows():
            file.write(f"### {row['Title']}\n\n")
            file.write(f"*Subtitle:* {row['Subtitle']}\n\n")
            file.write(f"*Author:* {row['Author']}\n\n")
            file.write(f"*Edition:* {row['Edition']}\n\n")
            file.write(f"*Description:* {row['Description']}\n\n")
            file.write(f"![Book Image]({row['Image Link']})\n\n")
            file.write("---\n\n")

# Load CSV file
df = pd.read_csv('books.csv')  # Replace 'books.csv' with your CSV file path

# Initialize new columns in DataFrame
df['Title'] = ''
df['Subtitle'] = ''
df['Author'] = ''
df['Edition'] = ''
df['Description'] = ''
df['Image Link'] = ''

# Update DataFrame with book information
for index, row in df.iterrows():
    info = get_book_info(row['ISBN'])
    df.at[index, 'Title'] = info[0]
    df.at[index, 'Subtitle'] = info[1]
    df.at[index, 'Author'] = info[2]
    df.at[index, 'Edition'] = info[3]
    df.at[index, 'Description'] = info[4]
    df.at[index, 'Image Link'] = info[5]

# Save the updated DataFrame to a Markdown file
save_to_markdown(df, 'updated_books.md')  # The output will be saved as 'updated_books.md'
