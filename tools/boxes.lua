-- Pandoc Lua filter for the study-primer boxes.
-- build-site.sh rewrites "\begin{example}[Title]" to
-- "\begin{example}\begin{boxtitle}Title\end{boxtitle}" so the title survives
-- pandoc's LaTeX reader; this filter turns the resulting Divs into titled boxes
-- and numbers examples and practice problems by section, as the LaTeX does.

local labels = {
  example  = "Example",
  solution = "Solution",
  keyfact  = "Key fact",
  trap     = "Trap",
  practice = "Practice",
}
local section = 0
local counters = { example = 0, practice = 0 }

-- "(A) 0.40 (B) 0.46 ..." answer lines become one flex row of five choices.
local function choice_row(para)
  if para.t ~= "Para" then return para end
  local first = para.content[1]
  if not (first and first.t == "Str" and first.text:match("^%([A-E]%)")) then return para end
  local spans, cur = {}, nil
  for _, inl in ipairs(para.content) do
    if inl.t == "Str" and inl.text:match("^%([A-E]%)") then
      if cur then table.insert(spans, pandoc.Span(cur, { class = "choice" })) end
      cur = pandoc.Inlines{}
    end
    if cur then
      if inl.t == "Str" then inl.text = inl.text:gsub("\194\160", " ") end
      cur:insert(inl)
    end
  end
  if cur then table.insert(spans, pandoc.Span(cur, { class = "choice" })) end
  return pandoc.Div({ pandoc.Plain(spans) }, { class = "choices" })
end

return {
  { traverse = "topdown",
    Header = function(h)
      if h.level >= 4 then  -- \paragraph{}: bold run-in heading, no number
        h.classes:insert("unnumbered"); return h
      end
      if h.level == 1 and not h.classes:includes("unnumbered") then
        section = section + 1
        counters.example, counters.practice = 0, 0
      end
    end,
    Div = function(div)
      local kind = div.classes[1]
      if not labels[kind] then return nil end
      local title
      local first = div.content[1]
      if first and first.t == "Div" and first.classes:includes("boxtitle") then
        title = first.content[1] and first.content[1].content or pandoc.Inlines{}
        div.content:remove(1)
      end
      local label = labels[kind]
      if counters[kind] then
        counters[kind] = counters[kind] + 1
        label = label .. " " .. section .. "." .. counters[kind]
      end
      local head = pandoc.Inlines{ pandoc.Span(pandoc.Str(label), { class = "box-label" }) }
      if title and #title > 0 then
        head:insert(pandoc.Str(": "))
        head:extend(title)
      end
      local body = div.content:map(choice_row)
      body:insert(1, pandoc.Div({ pandoc.Plain(head) }, { class = "box-title" }))
      return pandoc.Div(body, { class = "box " .. kind })
    end },
}
