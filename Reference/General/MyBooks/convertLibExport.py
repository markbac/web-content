import pandas as pd
import re

def format_anchor(title):
    """Format the title to create a valid anchor link for Markdown."""
    # Remove all non-alphanumeric characters except spaces, then replace spaces with hyphens
    return re.sub(r"[^\w\s]", '', title).replace(' ', '-')

def format_isbn(isbn):
    """Format the ISBN to remove trailing '.0'."""
    return str(isbn).split('.')[0] if pd.notna(isbn) else 'N/A'

def write_field(file, field_name, value):
    """Write a field to the Markdown file if it's present."""
    if value and value != 'N/A':
        file.write(f"*{field_name}:* {value}\n\n")

def convert_rating_to_stars(rating):
    """Convert numeric rating to star representation."""
    try:
        rating = float(rating)
        return '★' * int(rating) + '☆' * (5 - int(rating))
    except ValueError:
        return 'N/A'

def create_table_of_contents(titles):
    """Create a table of contents for the Markdown file, sorted alphabetically."""
    sorted_titles = sorted(titles, key=lambda s: s[0].upper())
    toc = "## Table of Contents\n"
    current_section = ""

    for title in sorted_titles:
        section = title[0].upper()
        if section.isdigit():
            section = "0-9"
        if section != current_section:
            toc += f"\n### {section}\n"
            current_section = section

        anchor_title = format_anchor(title)
        toc += f"- [{title}](#{anchor_title})\n"

    return toc + "\n"

def save_to_markdown(group_df, bookshelf_name):
    """Save the book details to a Markdown file named after the bookshelf."""
    filename = f"{bookshelf_name.replace(' ', '_')}_books.md"
    titles = group_df['Title'].tolist()
    with open(filename, 'w') as file:
        file.write(create_table_of_contents(titles))
        for _, row in group_df.iterrows():
            anchor_title = format_anchor(row['Title'])
            file.write(f"### <a name='{anchor_title}'></a>{row['Title']}\n\n")
            if row['Image Url'] and row['Image Url'] != 'N/A':
                file.write(f"![Book Image]({row['Image Url']})\n\n")
            stars = convert_rating_to_stars(row['Rating'])
            write_field(file, "Author", row['Author'])
            write_field(file, "Published Date", row['Published Date'])
            write_field(file, "Pages", row['Pages'])
            file.write(f"*ISBN:* {format_isbn(row['ISBN'])}\n\n")
            write_field(file, "Summary", row['Summary'])
            file.write(f"*Rating:* {stars}\n\n")
            file.write("---\n\n")

# Load CSV file
df = pd.read_csv('HandyLib-19Jan24.csv')  # Replace with your actual CSV file path

# Convert ISBNs to string and remove trailing '.0'
df['ISBN'] = df['ISBN'].apply(format_isbn)

# Group data by 'BookShelf'
grouped = df.groupby('BookShelf')

# Process each group
for bookshelf_name, group_df in grouped:
    save_to_markdown(group_df, bookshelf_name)
