type todo = {
  text: string,
  done: bool,
}

type state = {
  todos: array<todo>,
  input: string,
}

type actions = Add | Remove(int) | RemoveAll | Toggle(int) | Input(string)

let reducer = (state, action) =>
  switch action {
    | Add =>
     let todos = state.input !== "" ?
      state.todos->Js.Array2.concat([{ text: state.input, done : false }])
      : state.todos

     { input: "", todos }
    | Remove(index) =>
     let todos = state.todos->Js.Array2.filteri((_, i) => index !== i)

     { ...state, todos }
    | RemoveAll =>
      { ...state, todos: [] }
    | Toggle(index) =>
      let todos = state.todos->Js.Array2.mapi(
        (todo, i) => i === index ? {...todo, done: !todo.done} : todo
      )

      { ...state, todos }
    | Input(value) =>
      { ...state, input: value }
  }

let initalState = {
  todos: [
    { text: "learn rescript", done: false },
    { text: "make a todo list", done: false }
  ],
  input: "",
}

@react.component
let make = () => {
  let (state, dispatch) = React.useReducer(reducer, initalState)

  let { input, todos } = state

  let onKeyDown = (e) => {
    let key = e->ReactEvent.Keyboard.key
    switch key {
      | "Enter" => {
         e->ReactEvent.Keyboard.preventDefault
         Add->dispatch
      }
      | _ => ()
    }
  }

  <div>
    <h3>{"Todo list"->React.string}</h3>
    <div>
      <input type_="text"
        value={input}
        onKeyDown={onKeyDown}
        onInput={e => ReactEvent.Form.currentTarget(e)["value"]->Input->dispatch} />
      <button onClick={_ => Add->dispatch}>{"Add"->React.string}</button>
      <button onClick={_ => RemoveAll->dispatch}>{"RemoveAll"->React.string}</button>
    </div>
    <ul>
      { todos->Js.Array2.mapi((todo, i) =>
        <li>
            <span
              style={
                ReactDOM.Style.make(
                  ~fontWeight="800",
                  ()
                )
              }
            >{ `${string_of_int(i + 1)}.`->React.string }</span>
            <input
              type_="checkbox"
              checked={todo.done}
              onClick={_ => i->Toggle->dispatch} />
            <span
              className={todo.done ? "done" : ""}>
              {todo.text->React.string}
            </span>
            <button onClick={_ => i->Remove->dispatch}>{"X"->React.string}</button>
        </li>
      )->React.array}
    </ul>
  </div>
}
