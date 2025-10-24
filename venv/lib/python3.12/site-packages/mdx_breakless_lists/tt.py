from markdown import markdown

text = "This line is before the list starts" \
       "\n1. List 1" \
       "\n\n\tList 2 is here:" \
       "\n\t* nested item" \
       "\n\t* nested item" \
       "\n" \
       "\n\tsubtitle" \
       "\n\t- new nested item"

# html = markdown(text, extensions=['nl2br', 'mdx_breakless_lists'])
html = markdown(text, extensions=['mdx_breakless_lists'])
# html = markdown(text)
print(html)
with open('test.html', 'w') as outfile:
    outfile.write(html)
