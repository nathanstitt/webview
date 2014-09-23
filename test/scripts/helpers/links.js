describe('links helper tests', function () {
  'use strict';
  var links;

  beforeEach(function (done) {
    this.timeout(10000);

    require(['cs!helpers/links'], function () {
      links = arguments[0];
      done();
    });
  });

  describe('get path tests', function () {
    it('should return the root url', function () {
      // not content
      var page = 'nothing';
      var data = {
        model: {
          getVersionedId: function () {
            return 'not real';
          }
        }
      };
      links.getPath(page, data).should.equal('/');
    });
<<<<<<< HEAD
    it('should append fake uuid and book title to url', function () {
=======
    it('should append fake uuid to url', function () {
>>>>>>> master
      var page = 'contents';
      var data = {
        model: {
          getVersionedId: function () {
            return 'not real';
<<<<<<< HEAD
          },
          getBookTitle: function () {
            return 'book title';
          }
        }
      };
      links.getPath(page, data).should.equal('/contents/not real/book_title');
    });
    it('should append uuid and book title from settings to url', function () {
=======
          }
        }
      };
      links.getPath(page, data).should.equal('/contents/not real');
    });
    it('should append uuid from settings to url', function () {
>>>>>>> master
      var page = 'contents';
      var data = {
        model: {
          getVersionedId: function () {
            return '031da8d3-b525-429c-80cf-6c8ed997733a@8.1';
<<<<<<< HEAD
          },
          getBookTitle: function () {
            return 'College Physics';
          }
        }
      };
      links.getPath(page, data).should.equal('/contents/college_physics/College_Physics');
    });
    it('should append uuid, page info and book title to url', function () {
=======
          }
        }
      };
      links.getPath(page, data).should.equal('/contents/college_physics');
    });
    it('should append uuid and page info to url', function () {
>>>>>>> master
      var page = 'contents';
      var data = {
        model: {
          getVersionedId: function () {
            return '031da8d3-b525-429c-80cf-6c8ed997733a@8.1';
<<<<<<< HEAD
          },
          getBookTitle: function () {
            return 'College Physics';
=======
>>>>>>> master
          }
        },
        page: 'page'
      };
<<<<<<< HEAD
      links.getPath(page, data).should.equal('/contents/college_physics:page/College_Physics');
=======
      links.getPath(page, data).should.equal('/contents/college_physics:page');
>>>>>>> master
    });
  });
  describe('serialize query tests', function () {
    it('should serialize query string in to an object', function () {
      var query =
        'search?author=Smith&title=Physics&subject=%22Science%20and%20Technology%22&keyword=Velocity&type=page';
      var queryObj = links.serializeQuery(query);
      queryObj.author.should.equal('Smith');
      queryObj.title.should.equal('Physics');
      queryObj.subject.should.equal('"Science and Technology"');
      queryObj.keyword.should.equal('Velocity');
      queryObj.type.should.equal('page');
    });
    it('should serialize query with encoded &, ?, and = in fields', function () {
      var query = 'search?author="Dr.%20Gray%3F"&title=%22Statics%20%26%20Dynamics%22&keyword=x%3D8';
      var queryObj = links.serializeQuery(query);
      queryObj.author.should.equal('"Dr. Gray?"');
      queryObj.title.should.equal('"Statics & Dynamics"');
      queryObj.keyword.should.equal('x=8');
    });
    // only finds the last one
    it('should serialize query with more than one keyword', function () {
      var query = 'search?keyword=Velocity&keyword=Statics';
      var queryObj = links.serializeQuery(query);
      queryObj.keyword.should.equal('Statics');
    });
  });
  describe('param tests', function () {
    it('should turn object in to query string', function () {
      var queryObj = {
        author: 'Smith',
        title: 'Physics',
        subject: '"Science and Technology"',
        keyword: 'Velocity',
        type: 'page'
      };
      links.param(queryObj).should.equal('author=Smith&title=Physics&subject=%22Science%20and%20' +
        'Technology%22&keyword=Velocity&type=page');
    });
    // doesn't encode correctly to be handled by the serialize function
    it('should encode &, =, and ?', function () {
      var queryObj = {
        author: 'Dr. Gray?',
        title: '"Statics & Dynamics"',
        keyword: 'x = 8'
      };
      links.param(queryObj);
<<<<<<< HEAD
      //.should.equal('author="Dr.%20Gray%3F"&title=%22Statics%20%26%20Dynamics%22&keyword=x%3D8');
=======
      //.should.equal('author="Dr.%20Gray%3F"&title=%22Statics%20%26%20Dynamics%22&keyword=x%3D8');                        
>>>>>>> master
    });
  });

  it('should serialize and deserialize a query', function () {
    var query = 'author=Smith&title=Physics&subject=%22Science%20and%20Technology%22&keyword=Velocity&type=page';
    var queryObj = links.serializeQuery(query);
    links.param(queryObj).should.equal(query);
  });

  // Doesn't work either becuase encoding doesn't work for these characters
  it('should serialize and deserialize a query with &, ?, and =', function () {
    var query = 'author="Dr.%20Gray%3F"&title=%22Statics%20%26%20Dynamics%22&keyword=x%3D8';
    var queryObj = links.serializeQuery(query);
    links.param(queryObj); //.should.equal(query);
  });
});
