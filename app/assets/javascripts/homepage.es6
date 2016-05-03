!function() {

  const { Component, PropTypes } = React;

  class Homepage extends Component {
    render() {
      return (
        <div className="centered-content zoom">
          <h1>lolCupid</h1>
          <h4>Champion recommendations based on what you already love</h4>
          <LolCupid.Search champions={this.props.champions} />
        </div>
      );
    }
  }

  LolCupid.Homepage = Homepage;

}();
